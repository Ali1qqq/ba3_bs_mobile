import 'dart:developer';

import 'package:ba3_bs_mobile/features/bond/service/bond/floating_bond_details_launcher.dart';
import 'package:ba3_bs_mobile/features/bond/ui/screens/bond_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/bond_model.dart';
import '../../service/bond/bond_utils.dart';
import '../pluto/bond_details_pluto_controller.dart';
import 'bond_details_controller.dart';
import 'bond_search_controller.dart';

class AllBondsController extends FloatingBondDetailsLauncher {
  final DataSourceRepository<BondModel> _bondsFirebaseRepo;

  late bool isDebitOrCredit;
  List<BondModel> bonds = [];
  bool isLoading = true;

  AllBondsController(this._bondsFirebaseRepo);

  // Services
  late final BondUtils _bondUtils;

  // Initializer
  void _initializeServices() {
    _bondUtils = BondUtils();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    // getAllBondTypes();
  }

  BondModel getBondById(String bondId) => bonds.firstWhere((bond) => bond.payGuid == bondId);

  Future<void> fetchAllBonds() async {
    log('fetchBonds');
    final result = await _bondsFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBonds) => bonds.assignAll(fetchedBonds),
    );

    isLoading = false;
    update();
  }

  List<BondModel> getBondsByType(String bondTypeId) => bonds.where((bond) => bond.payTypeGuid! == bondTypeId).toList();

  Future<void> openFloatingBondDetails(BuildContext context, BondType bondTypeModel, {BondModel? bondModel}) async {
    await fetchAllBonds();

    if (!context.mounted) return;

    List<BondModel> bondsByCategory = getBondsByType(bondModel?.payTypeGuid ?? bondTypeModel.typeGuide);

    final BondModel lastBondModel = bondModel ?? _bondUtils.appendEmptyBondModel(bondsByCategory, bondTypeModel);

    _openBondDetailsFloatingWindow(
      context: context,
      modifiedBonds: bondsByCategory,
      lastBondModel: lastBondModel,
      bondType: bondTypeModel,
    );
  }

  void openBondDetailsById(String bondId, BuildContext context) async {
    final BondModel bondModel = await fetchBondsById(bondId);
    if (!context.mounted) return;

    openFloatingBondDetails(context, BondType.byTypeGuide(bondModel.payTypeGuid!), bondModel: bondModel);
  }

  Future<BondModel> fetchBondsById(String bondId) async {
    late BondModel bondModel;

    final result = await _bondsFirebaseRepo.getById(bondId);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBonds) => bondModel = fetchedBonds,
    );
    return bondModel;
  }

  // Opens the 'Bond Details' floating window.
  void _openBondDetailsFloatingWindow({
    required BuildContext context,
    required List<BondModel> modifiedBonds,
    required BondModel lastBondModel,
    required BondType bondType,
  }) {
    final String controllerTag = AppServiceUtils.generateUniqueTag('BondController');

    final Map<String, GetxController> controllers = setupControllers(
      params: {
        'tag': controllerTag,
        'bondType': bondType,
        'bondsFirebaseRepo': _bondsFirebaseRepo,
        'bondDetailsPlutoController': BondDetailsPlutoController(bondType),
        'bondSearchController': BondSearchController(),
      },
    );

    final bondDetailsController = controllers['bondDetailsController'] as BondDetailsController;
    final bondDetailsPlutoController = controllers['bondDetailsPlutoController'] as BondDetailsPlutoController;
    final bondSearchController = controllers['bondSearchController'] as BondSearchController;

    initializeBondSearch(
      currentBond: lastBondModel,
      allBonds: modifiedBonds,
      bondSearchController: bondSearchController,
      bondDetailsController: bondDetailsController,
      bondDetailsPlutoController: bondDetailsPlutoController,
    );

    launchFloatingWindow(
      context: context,
      minimizedTitle: BondType.byTypeGuide(lastBondModel.payTypeGuid!).value,
      floatingScreen: BondDetailsScreen(
        fromBondById: false,
        bondDetailsController: bondDetailsController,
        bondDetailsPlutoController: bondDetailsPlutoController,
        bondSearchController: bondSearchController,
        tag: controllerTag,
      ),
    );
  }

  void initializeBondSearch({
    required BondModel currentBond,
    required List<BondModel> allBonds,
    required BondSearchController bondSearchController,
    required BondDetailsController bondDetailsController,
    required BondDetailsPlutoController bondDetailsPlutoController,
  }) {
    bondSearchController.initialize(
      bond: currentBond,
      bondsByCategory: allBonds,
      bondDetailsController: bondDetailsController,
      bondDetailsPlutoController: bondDetailsPlutoController,
    );
  }
}

/*
* 


  void openBondDetailsById(String bondId) {
    final BondModel bondModel = getBondById(bondId);

    List<BondModel> bondsByCategory = getBondsByType(bondModel.bondTypeModel.bondTypeId!);

    _navigateToBondDetailsWithModel(bondModel, bondsByCategory, fromBondById: true);
  }

  Future<void> openLastBondDetails(BondTypeModel bondTypeModel, AddBondPlutoController addBondPlutoController) async {
    await fetchAllBonds();

    List<BondModel> bondsByCategory = getBondsByType(bondTypeModel.bondTypeId!);

    if (bondsByCategory.isEmpty) {
      _navigateToAddBond(bondTypeModel, addBondPlutoController);
      return;
    }

    final BondModel lastBondModel = _bondUtils.appendEmptyBondModel(bondsByCategory, bondTypeModel);

    _navigateToBondDetailsWithModel(lastBondModel, bondsByCategory);
  }

  Future<void> openFloatingBondDetails(BuildContext context, BondTypeModel bondTypeModel) async {
    await fetchAllBonds();

    if (!context.mounted) return;

    List<BondModel> bondsByCategory = getBondsByType(bondTypeModel.bondTypeId!);

    final BondModel lastBondModel = _bondUtils.appendEmptyBondModel(bondsByCategory, bondTypeModel);

    _openBondDetailsFloatingWindow(
      context: context,
      modifiedBonds: bondsByCategory,
      lastBondModel: lastBondModel,
    );
  }

  
  void _navigateToAddBond(BondTypeModel bondTypeModel, AddBondPlutoController addBondPlutoController) {
    Get.find<BondDetailsController>().navigateToAddBondScreen(bondTypeModel, addBondPlutoController);
  }

  void _navigateToBondDetailsWithModel(BondModel bondModel, List<BondModel> allBonds, {bool fromBondById = false}) {
    final String controllerTag = AppServiceUtils.generateUniqueTag('BondDetailsController');

    final Map<String, dynamic> controllers = initializeControllers(
      params: {
        'tag': controllerTag,
        'bondsFirebaseRepo': _bondsFirebaseRepo,
        'bondDetailsPlutoController': BondDetailsPlutoController(),
        'bondSearchController': BondSearchController(),
      },
    );

    final bondDetailsController = controllers['bondDetailsController'] as BondDetailsController;
    final bondDetailsPlutoController = controllers['bondDetailsPlutoController'] as BondDetailsPlutoController;
    final bondSearchController = controllers['bondSearchController'] as BondSearchController;

    bondDetailsController.updateBondDetailsOnScreen(bondModel, bondDetailsPlutoController);

    initializeBondSearch(
      currentBond: bondModel,
      allBonds: allBonds,
      bondSearchController: bondSearchController,
      bondDetailsController: bondDetailsController,
      bondDetailsPlutoController: bondDetailsPlutoController,
    );

    Get.toNamed(AppRoutes.bondDetailsScreen, arguments: {
      'fromBondById': fromBondById,
      'bondDetailsController': bondDetailsController,
      'bondDetailsPlutoController': bondDetailsPlutoController,
      'bondSearchController': bondSearchController,
      'tag': controllerTag,
    });
  }

 
*/
