import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/features/bond/service/bond/floating_bond_details_launcher.dart';
import 'package:ba3_bs_mobile/features/bond/ui/screens/bond_details_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/json_file_operations/implementations/import_export_repo.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/bond_model.dart';
import '../../service/bond/bond_utils.dart';
import '../pluto/bond_details_pluto_controller.dart';
import 'bond_details_controller.dart';
import 'bond_search_controller.dart';

class AllBondsController extends FloatingBondDetailsLauncher {
  final CompoundDatasourceRepository<BondModel, BondType> _bondsFirebaseRepo;
  final ImportExportRepository<BondModel> _jsonImportExportRepo;

  late bool isDebitOrCredit;
  List<BondModel> bonds = [];
  bool isLoading = true;

  AllBondsController(this._bondsFirebaseRepo, this._jsonImportExportRepo);

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
  }

  BondModel getBondById(String bondId) => bonds.firstWhere((bond) => bond.payGuid == bondId);

  Future<void> fetchAllBondsByType(BondType itemTypeModel) async {
    log('fetchAllBondsByType');
    final result = await _bondsFirebaseRepo.getAll(itemTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBonds) => bonds.assignAll(fetchedBonds),
    );

    isLoading = false;
    update();
  }

  Future<void> fetchAllBondsLocal() async {
    log('fetchAllBondsLocal');

    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = _jsonImportExportRepo.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedBonds) {
          log('bonds.length ${bonds.length}');
          log('bonds.lastOrNull ${bonds.firstOrNull?.toJson()}');

          bonds.assignAll(fetchedBonds);
        },
      );
    } else {
      // User canceled the picker
    }

    isLoading = false;
    update();
  }

  Future<void> openFloatingBondDetails(BuildContext context, BondType bondTypeModel, {BondModel? bondModel}) async {
    // await fetchAllBondsLocal();
    await fetchAllBondsByType(bondTypeModel);

    if (!context.mounted) return;

    final BondModel lastBondModel = bondModel ?? _bondUtils.appendEmptyBondModel(bonds, bondTypeModel);

    _openBondDetailsFloatingWindow(
      context: context,
      modifiedBonds: bonds,
      lastBondModel: lastBondModel,
      bondType: bondTypeModel,
    );
  }

  void openBondDetailsById(String bondId, BuildContext context, BondType itemTypeModel) async {
    final BondModel bondModel = await fetchBondsById(bondId, itemTypeModel);
    if (!context.mounted) return;

    openFloatingBondDetails(context, BondType.byTypeGuide(bondModel.payTypeGuid!), bondModel: bondModel);
  }

  Future<BondModel> fetchBondsById(String bondId, BondType itemTypeModel) async {
    late BondModel bondModel;

    final result = await _bondsFirebaseRepo.getById(id: bondId, itemTypeModel: itemTypeModel);

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
