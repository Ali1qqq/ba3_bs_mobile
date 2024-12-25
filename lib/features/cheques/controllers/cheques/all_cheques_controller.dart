import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/cheques_model.dart';
import '../../service/cheques/cheques_utils.dart';
import '../../service/cheques/floating_cheques_details_launcher.dart';
import '../../ui/screens/cheques_details.dart';
import 'cheques_details_controller.dart';
import 'cheques_search_controller.dart';

class AllChequesController extends FloatingChequesDetailsLauncher {
  final DataSourceRepository<ChequesModel> _chequesFirebaseRepo;

  late bool isDebitOrCredit;
  List<ChequesModel> chequesList = [];
  bool isLoading = true;

  AllChequesController(this._chequesFirebaseRepo);

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

  ChequesModel getChequesById(String chequesId) =>
      chequesList.firstWhere((cheques) => cheques.chequesGuid == chequesId);

  Future<void> fetchAllCheques() async {
    log('fetchCheques');
    final result = await _chequesFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedCheques) => chequesList = fetchedCheques,
    );

    isLoading = false;
    update();
  }

  List<ChequesModel> getChequesByType(String chequesTypeId) =>
      chequesList.where((cheques) => cheques.chequesTypeGuid! == chequesTypeId).toList();

  Future<void> openFloatingChequesDetails(BuildContext context, ChequesType chequesTypeModel,
      {ChequesModel? chequesModel}) async {
    await fetchAllCheques();

    if (!context.mounted) return;

    List<ChequesModel> chequesByCategory =
        getChequesByType(chequesModel?.chequesTypeGuid ?? chequesTypeModel.typeGuide);

    final ChequesModel lastChequesModel =
        chequesModel ?? _chequesUtils.appendEmptyChequesModel(chequesByCategory, chequesTypeModel);

    _openChequesDetailsFloatingWindow(
      context: context,
      modifiedCheques: chequesByCategory,
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

  void navigateToChequesScreen({required bool onlyDues}) =>
      Get.toNamed(AppRoutes.showAllChequesScreen, arguments: onlyDues);

  void openChequesDetailsById(String chequesId, BuildContext context) async {
    final ChequesModel chequesModel = await fetchChequesById(chequesId);
    if (!context.mounted) return;

    openFloatingChequesDetails(context, ChequesType.byTypeGuide(chequesModel.chequesTypeGuid!),
        chequesModel: chequesModel);
  }

  Future<ChequesModel> fetchChequesById(String chequesId) async {
    late ChequesModel chequesModel;

    final result = await _chequesFirebaseRepo.getById(chequesId);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedCheques) => chequesModel = fetchedCheques,
    );
    return chequesModel;
  }
}
