import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs_mobile/features/bond/service/bond/floating_bond_details_launcher.dart';
import 'package:ba3_bs_mobile/features/bond/ui/screens/bond_details_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/json_file_operations/implementations/import_export_repo.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/bond_model.dart';
import '../../service/bond/bond_utils.dart';
import '../pluto/bond_details_pluto_controller.dart';
import 'bond_details_controller.dart';
import 'bond_search_controller.dart';

class AllBondsController extends FloatingBondDetailsLauncher
    with EntryBondsGenerator, FirestoreSequentialNumbers, FloatingLauncher, AppNavigator {
  final CompoundDatasourceRepository<BondModel, BondType> _bondsFirebaseRepo;
  final ImportExportRepository<BondModel> _jsonImportExportRepo;

  late bool isDebitOrCredit;
  List<BondModel> bonds = [];
  Map<BondType, List<BondModel>> nestedBonds = {};
  Map<String, List<BondModel>> bondsByTypeGuid = {};
  List<BondModel> allNestedBonds = [];
  bool isLoading = true;

  Rx<RequestState> saveAllBondsRequestState = RequestState.initial.obs;
  Rx<RequestState> allBondsRequestState = RequestState.initial.obs;

  // Initialize a progress observable
  RxDouble uploadProgress = 0.0.obs;

  AllBondsController(this._bondsFirebaseRepo, this._jsonImportExportRepo);

  // Services
  late final BondUtils _bondUtils;

  // Initializer
  void _initializeServices() async {
    _bondUtils = BondUtils();
    await fetchAllBondsCountsByTypes(BondType.values);
  }

  Future<void> fetchAllNestedBonds() async {
    // getAllNestedBondsRequestState.value = RequestState.loading;

    final result = await _bondsFirebaseRepo.fetchAllNested(BondType.values);

    result.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (fetchedNestedBonds) => nestedBonds.assignAll(fetchedNestedBonds),
    );
    bondsByTypeGuid.assignAll(nestedBonds.map(
          (bondType, bonds) => MapEntry(bondType.typeGuide, bonds),
    ));
    nestedBonds.forEach((k, v) => log('bond Type: ${k.label} has ${v.length} bonds'));

    allNestedBonds.assignAll(nestedBonds.values.expand((bonds) => bonds).toList());

    log("allNestedBonds is ${allNestedBonds.length}");

    // getAllNestedBondsRequestState.value = RequestState.success;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  Future<void> refreshBondsTypes() async => await fetchAllBondsCountsByTypes(BondType.values);

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
      final result = await _jsonImportExportRepo.importXmlFile(file);

      result.fold(
            (failure) => AppUIUtils.onFailure(failure.message),
            (fetchedBonds) async {
          log('bonds.length ${fetchedBonds.length}');
          bonds.assignAll(fetchedBonds);
          if (bonds.isNotEmpty) {
            log('bonds.length ${fetchedBonds.last.toJson()}');

            saveAllBondsRequestState.value = RequestState.loading;

            await _bondsFirebaseRepo.saveAllNested(items: bonds, itemIdentifiers: BondType.values);
            await createAndStoreEntryBonds(
              sourceModels: bonds,
              sourceNumbers: bonds.select((bond) => bond.payNumber).toList(),
              onProgress: (progress) {
                uploadProgress.value = progress; // Update progress
                log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
              },
            );
          }
          saveAllBondsRequestState.value = RequestState.success;
          AppUIUtils.onSuccess('تم تحميل السندات بنجاح');
        },
      );
    }

    isLoading = false;
    update();
  }

  Future<List<BondModel>> bondsCountByType(BondType bondType) async {
    int bondsCountByType = await getLastNumber(
      //   category:'${read<MigrationController>().currentVersion}${ApiConstants.bonds}',
      category: ApiConstants.bonds,
      entityType: bondType.label,
    );

    return _bondUtils.appendEmptyBondModelNew(bondType, bondsCountByType);
  }

  Future<void> openFloatingBondDetails(BuildContext context, BondType bondType, {BondModel? currentBondModel}) async {
    final bonds = await bondsCountByType(bondType);

    if (!context.mounted) return;

    _openBondDetailsFloatingWindow(
      context: context,
      bondType: bondType,
      lastBondNumber: bonds.last.payNumber!,
      currentBond: currentBondModel ?? bonds.last,
    );
  }

  void openBondDetailsById(String bondId, BuildContext context, BondType itemTypeModel) async {
    final BondModel bondModel = await fetchBondsById(bondId, itemTypeModel);
    if (!context.mounted) return;

    openFloatingBondDetails(context, BondType.byTypeGuide(bondModel.payTypeGuid!), currentBondModel: bondModel);
  }

  Future<BondModel> fetchBondsById(String bondId, BondType itemTypeModel) async {
    late BondModel bondModel;

    final result = await _bondsFirebaseRepo.getById(id: bondId, itemIdentifier: itemTypeModel);

    result.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (fetchedBonds) => bondModel = fetchedBonds,
    );
    return bondModel;
  }

  Future<Either<Failure, List<BondModel>>> fetchBondByNumber({required BondType bondType, required int bondNumber}) async {
    final result = await _bondsFirebaseRepo.fetchWhere(
      itemIdentifier: bondType,
      field: ApiConstants.bondNumber,
      value: bondNumber,
    );

    return result;
  }

  // Opens the 'Bond Details' floating window.
  void _openBondDetailsFloatingWindow({
    required BuildContext context,
    required BondType bondType,
    required BondModel currentBond,
    required int lastBondNumber,
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
      currentBond: currentBond,
      lastBondNumber: lastBondNumber,
      bondSearchController: bondSearchController,
      bondDetailsController: bondDetailsController,
      bondDetailsPlutoController: bondDetailsPlutoController,
    );

    launchFloatingWindow(
      context: context,
      minimizedTitle: BondType
          .byTypeGuide(currentBond.payTypeGuid!)
          .value,
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
    required int lastBondNumber,
    required BondSearchController bondSearchController,
    required BondDetailsController bondDetailsController,
    required BondDetailsPlutoController bondDetailsPlutoController,
  }) {
    bondSearchController.initialize(
      currentBond: currentBond,
      lastBondNumber: lastBondNumber,
      bondDetailsController: bondDetailsController,
      bondDetailsPlutoController: bondDetailsPlutoController,
    );
  }

  final allBondsCountsByType = <BondType, int>{};

  bool isBondsLoading = true;

  int allBondsCounts(BondType bondTypeModel) {
    return allBondsCountsByType[bondTypeModel] ?? 0;
  }

  Future<void> fetchAllBondsCountsByTypes(List<BondType> fetchedBondTypes) async {
    allBondsRequestState.value = RequestState.loading;
    final List<Future<void>> fetchTasks = [];
    final errors = <String>[]; // Collect error messages.

    for (final bondTypeModel in fetchedBondTypes) {
      fetchTasks.add(
        _bondsFirebaseRepo.count(itemIdentifier: bondTypeModel).then((result) {
          result.fold(
                (failure) => errors.add('Failed to fetch count for ${bondTypeModel.label}: ${failure.message}'),
                (count) {
              allBondsCountsByType[bondTypeModel] = count;
            },
          );
        }),
      );
    }

    // Wait for all tasks to complete.
    await Future.wait(fetchTasks);
    allBondsRequestState.value = RequestState.success;
    update();
    // Handle errors if any.
    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some counts failed to fetch: ${errors.join(', ')}');
    }
  }

  void navigateToAllBondScreen() => to(AppRoutes.allBondsScreen);

  Future<void> fetchAllBondByType(BondType bondType, BuildContext context) async {
    isBondsLoading = true;
    update();

    navigateToAllBondScreen();
    final result = await _bondsFirebaseRepo.getAll(bondType);

    result.fold(
          (failure) => AppUIUtils.onFailure('لا يوجد سندات  في ${bondType.value}'),
          (fetchedPendingBonds) {
        bonds.assignAll(fetchedPendingBonds);
      },
    );

    isBondsLoading = false;
    update();
  }
}