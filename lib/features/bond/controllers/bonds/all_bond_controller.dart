import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/features/bond/service/bond/floating_bond_details_launcher.dart';
import 'package:ba3_bs_mobile/features/bond/ui/screens/bond_details_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/error/failure.dart';
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

class AllBondsController extends FloatingBondDetailsLauncher with EntryBondsGenerator, FirestoreSequentialNumbers {
  final CompoundDatasourceRepository<BondModel, BondType> _bondsFirebaseRepo;
  final ImportExportRepository<BondModel> _jsonImportExportRepo;

  late bool isDebitOrCredit;
  List<BondModel> bonds = [];
  bool isLoading = true;

  Rx<RequestState> saveAllBondsRequestState = RequestState.initial.obs;

  // Initialize a progress observable
  RxDouble uploadProgress = 0.0.obs;

  AllBondsController(this._bondsFirebaseRepo, this._jsonImportExportRepo);

  // Services
  late final BondUtils _bondUtils;

  // Initializer
  void _initializeServices() {
    _bondUtils = BondUtils();
    fetchAllBondsCountsByTypes(BondType.values);
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
      final result = await _jsonImportExportRepo.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedBonds) async {
          log('bonds.length ${fetchedBonds.length}');
          bonds.assignAll(fetchedBonds);
          if (bonds.isNotEmpty) {
            log('bonds.length ${fetchedBonds.last.toJson()}');

            saveAllBondsRequestState.value = RequestState.loading;

            await _bondsFirebaseRepo.saveAllNested(
              bonds,
              BondType.values,
              (progress) {},
            );
            await createAndStoreEntryBonds(
              sourceModels: bonds,
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

  Future<List<BondModel>> billsCountByType(BondType bondType) async {
    int billsCountByType = await getLastNumber(
      category: ApiConstants.bonds,
      entityType: bondType.label,
    );

    return _bondUtils.appendEmptyBillModelNew(bondType, billsCountByType);
  }

  Future<void> openFloatingBondDetails(BuildContext context, BondType bondType, {BondModel? bondModel}) async {
    // await fetchAllBondsLocal();
    // await fetchAllBondsByType(bondTypeModel);
    //
    // if (!context.mounted) return;
    //
    // final BondModel lastBondModel = bondModel ?? _bondUtils.appendEmptyBondModel(bonds, bondTypeModel);
    //
    // _openBondDetailsFloatingWindow(
    //   context: context,
    //   modifiedBonds: bonds,
    //   lastBondModel: lastBondModel,
    //   bondType: bondTypeModel,
    // );

    final bonds = await billsCountByType(bondType);

    if (!context.mounted) return;

    _openBondDetailsFloatingWindow(
      context: context,
      modifiedBonds: bonds,
      lastBondModel: bonds.last,
      bondType: bondType,
    );
  }

  void openBondDetailsById(String bondId, BuildContext context, BondType itemTypeModel) async {
    final BondModel bondModel = await fetchBondsById(bondId, itemTypeModel);
    if (!context.mounted) return;

    openFloatingBondDetails(context, BondType.byTypeGuide(bondModel.payTypeGuid!), bondModel: bondModel);
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
      newBond: currentBond,
      allBonds: allBonds,
      bondDetailsController: bondDetailsController,
      bondDetailsPlutoController: bondDetailsPlutoController,
    );
  }

  final allBondsCountsByType = <BondType, int>{};

  int allBondsCounts(BondType bondTypeModel) {
    return allBondsCountsByType[bondTypeModel] ?? 0;
  }

  Future<void> fetchAllBondsCountsByTypes(List<BondType> fetchedBondTypes) async {
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
    update();
    // Handle errors if any.
    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some counts failed to fetch: ${errors.join(', ')}');
    }
  }
}
