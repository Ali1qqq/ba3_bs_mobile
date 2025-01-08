import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/mixin/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/json_file_operations/implementations/import_export_repo.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/cheques_model.dart';
import '../../service/cheques_utils.dart';
import '../../service/floating_cheques_details_launcher.dart';
import '../../ui/screens/cheques_details.dart';
import 'cheques_details_controller.dart';
import 'cheques_search_controller.dart';

class AllChequesController extends FloatingChequesDetailsLauncher with AppNavigator {
  final CompoundDatasourceRepository<ChequesModel, ChequesType> _chequesFirebaseRepo;
  final ImportExportRepository<ChequesModel> _jsonImportExportRepo;

  late bool isDebitOrCredit;
  List<ChequesModel> chequesList = [];
  bool isLoading = true;

  AllChequesController(this._chequesFirebaseRepo, this._jsonImportExportRepo);

  // Services
  late final ChequesUtils _chequesUtils;

  // Initializer
  void _initializeServices() {
    _chequesUtils = ChequesUtils();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    // getAllChequesTypes();
  }

  ChequesModel getChequesById(String chequesId) => chequesList.firstWhere((cheques) => cheques.chequesGuid == chequesId);

  Future<void> fetchAllChequesLocal() async {
    log('fetchAllChequesLocal');

    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = _jsonImportExportRepo.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedCheques) {
          log('chequesList.length ${chequesList.length}');
          log('chequesList.firstOrNull ${chequesList.firstOrNull?.toJson()}');

          chequesList.assignAll(fetchedCheques);
        },
      );
    } else {
      // User canceled the picker
    }

    isLoading = false;
    update();
  }

  Future<void> fetchAllChequesByType(ChequesType itemTypeModel) async {
    log('fetchCheques');
    final result = await _chequesFirebaseRepo.getAll(itemTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedCheques) => chequesList = fetchedCheques,
    );

    isLoading = false;
    update();
  }

  Future<void> openFloatingChequesDetails(BuildContext context, ChequesType chequesTypeModel, {ChequesModel? chequesModel}) async {
    await fetchAllChequesByType(chequesTypeModel);

    if (!context.mounted) return;

    final ChequesModel lastChequesModel = chequesModel ?? _chequesUtils.appendEmptyChequesModel(chequesList, chequesTypeModel);

    _openChequesDetailsFloatingWindow(
      context: context,
      modifiedCheques: chequesList,
      lastChequesModel: lastChequesModel,
      chequesType: chequesTypeModel,
    );
  }

  // Opens the 'Cheques Details' floating window.
  void _openChequesDetailsFloatingWindow({
    required BuildContext context,
    required List<ChequesModel> modifiedCheques,
    required ChequesModel lastChequesModel,
    required ChequesType chequesType,
  }) {
    final String controllerTag = AppServiceUtils.generateUniqueTag('ChequesController');

    final Map<String, GetxController> controllers = setupControllers(
      params: {
        'tag': controllerTag,
        'chequesType': chequesType,
        'chequesFirebaseRepo': _chequesFirebaseRepo,
        'chequesSearchController': ChequesSearchController(),
      },
    );

    final chequesDetailsController = controllers['chequesDetailsController'] as ChequesDetailsController;
    final chequesSearchController = controllers['chequesSearchController'] as ChequesSearchController;

    initializeChequesSearch(
      currentCheques: lastChequesModel,
      allCheques: modifiedCheques,
      chequesDetailsController: chequesDetailsController,
      chequesSearchController: chequesSearchController,
    );

    launchFloatingWindow(
      context: context,
      defaultHeight: 0.65.sh,
      defaultWidth: 0.5.sw,
      minimizedTitle: ChequesType.byTypeGuide(lastChequesModel.chequesTypeGuid!).value,
      floatingScreen: ChequesDetailsScreen(
        tag: controllerTag,
        chequesTypeModel: chequesType,
        // fromChequesById: false,
        chequesDetailsController: chequesDetailsController, chequesSearchController: chequesSearchController,
      ),
    );
  }

  void initializeChequesSearch({
    required ChequesModel currentCheques,
    required List<ChequesModel> allCheques,
    required ChequesSearchController chequesSearchController,
    required ChequesDetailsController chequesDetailsController,
  }) {
    chequesSearchController.initialize(
      cheques: currentCheques,
      chequesByCategory: allCheques,
      chequesDetailsController: chequesDetailsController,
    );
  }

  void navigateToChequesScreen({required bool onlyDues}) => to(AppRoutes.showAllChequesScreen, arguments: onlyDues);

  void openChequesDetailsById(String chequesId, BuildContext context, ChequesType itemTypeModel) async {
    final ChequesModel chequesModel = await fetchChequesById(chequesId, itemTypeModel);
    if (!context.mounted) return;

    openFloatingChequesDetails(context, ChequesType.byTypeGuide(chequesModel.chequesTypeGuid!), chequesModel: chequesModel);
  }

  Future<ChequesModel> fetchChequesById(String chequesId, ChequesType itemTypeModel) async {
    late ChequesModel chequesModel;

    final result = await _chequesFirebaseRepo.getById(id: chequesId, itemTypeModel: itemTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedCheques) => chequesModel = fetchedCheques,
    );
    return chequesModel;
  }
}
