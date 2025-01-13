import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/dialogs/search_product_text_dialog.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bisc/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/router/app_routes.dart';
import 'package:ba3_bs_mobile/core/services/local_database/implementations/repos/local_datasource_repo.dart';
import 'package:ba3_bs_mobile/features/changes/data/model/changes_model.dart';
import 'package:ba3_bs_mobile/features/materials/service/material_from_handler.dart';
import 'package:ba3_bs_mobile/features/materials/service/material_service.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/services/firebase/implementations/repos/listen_datasource_repo.dart';
import '../../../core/services/firebase/implementations/services/firestore_uploader.dart';
import '../../../core/services/json_file_operations/implementations/import_export_repo.dart';
import '../../../core/utils/app_service_utils.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/material_model.dart';

class MaterialController extends GetxController with AppNavigator {
  final ImportExportRepository<MaterialModel> _jsonImportExportRepo;
  final LocalDatasourceRepository<MaterialModel> _materialsHiveRepo;
  final ListenDataSourceRepository<ChangesModel> _listenDataSourceRepository;

  MaterialController(
    this._jsonImportExportRepo,
    this._materialsHiveRepo,
    this._listenDataSourceRepository,
  );

  List<MaterialModel> materials = [];
  MaterialModel? selectedMaterial;

  late MaterialFromHandler materialFromHandler;
  late MaterialService _materialService;

  bool get isFromHandler => selectedMaterial == null ? false : true;

  @override
  onInit() {
    super.onInit();
    _initializer();
  }

  _initializer() {
    materialFromHandler = MaterialFromHandler();
    _materialService = MaterialService();
  }

  bool isLoading = false;

  Rx<RequestState> saveAllMaterialsRequestState = RequestState.initial.obs;

  Future<void> fetchMaterials() async {
    final result = await _materialsHiveRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedMaterial) => materials.assignAll(fetchedMaterial),
    );
  }

  Future<void> reloadMaterials() async {
    await fetchMaterials();
  }

  Future<void> saveAllMaterial(List<MaterialModel> materialsToSave) async {
    final result = await _materialsHiveRepo.saveAll(materialsToSave);

    result.fold((failure) => AppUIUtils.onFailure(failure.message), (savedMaterials) {
      log('materials length before add item: ${materials.length}');
      AppUIUtils.onSuccess('تم الحفظ بنجاح');
      reloadMaterials();
      log('materials length after add item: ${materials.length}');
    });
  }

  Future<void> deleteAllMaterial(List<MaterialModel> materialsToDelete) async {
    // Filter materials that match the IDs in materialsToDelete

    final copiedMaterials = materials.where((material) => materialsToDelete.any((e) => e.id == material.id)).toList();
    // Attempt to delete all matched materials

    final result = await _materialsHiveRepo.deleteAll(copiedMaterials);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => reloadMaterials(), // Remove all deleted materials
    );
  }

  Future<void> fetchAllMaterialFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = _jsonImportExportRepo.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedMaterial) => _handelFetchAllMaterialFromLocalSuccess(fetchedMaterial),
      );
    }
  }

  // Initialize a progress observable
  RxDouble uploadProgress = 0.0.obs;

  _handelFetchAllMaterialFromLocalSuccess(List<MaterialModel> fetchedMaterial) async {
    log('fetchedMaterial length ${fetchedMaterial.length}');
    log('fetchedMaterial first ${fetchedMaterial.first.toJson()}');

    saveAllMaterialsRequestState.value = RequestState.loading;

    materials.assignAll(fetchedMaterial);

    // Show progress in the UI
    FirestoreUploader firestoreUploader = FirestoreUploader();
    await firestoreUploader.sequentially(
      data: materials.map((item) => {...item.toJson(), 'docId': item.id}).toList(),
      collectionPath: ApiConstants.materials,
      onProgress: (progress) {
        uploadProgress.value = progress; // Update progress
        log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      },
    );

    saveAllMaterialsRequestState.value = RequestState.success;
  }

  void navigateToAllMaterialScreen() {
    to(AppRoutes.showAllMaterialsScreen);
  }

  Future<List<MaterialModel>> searchOfProductByText(query) async {
    await reloadMaterials();

    List<MaterialModel> searchedMaterials = [];

    query = AppServiceUtils.replaceArabicNumbersWithEnglish(query);

    String query2 = '';
    String query3 = '';

    if (query.contains(" ")) {
      query3 = query.split(" ")[0];
      query2 = query.split(" ")[1];
    } else {
      query3 = query;
      query2 = query;
    }

    searchedMaterials = materials.where((item) {
      bool prodName = item.matName.toString().toLowerCase().contains(query3.toLowerCase()) &&
          item.matName.toString().toLowerCase().contains(query2.toLowerCase());
      bool prodCode = item.matCode.toString().toLowerCase().contains(query.toLowerCase());
      bool prodBarcode = item.matBarCode != null ? item.matBarCode!.toLowerCase().contains(query.toLowerCase()) : false;
      return (prodName || prodCode || prodBarcode);
    }).toList();

    return searchedMaterials;
  }

  String? getMaterialNameById(String? id) {
    if (id == null || id.isEmpty) return '';
    return materials.firstWhereOrNull((material) => material.id == id)?.matName ?? "not fond this material";
  }

  String getMaterialBarcodeById(String? id) {
    if (id == null || id.isEmpty) return '0';

    reloadMaterials();

    final String matBarCode = materials.firstWhere((material) => material.id == id, orElse: () => MaterialModel()).matBarCode ?? '0';

    return matBarCode;
  }

  MaterialModel? getMaterialById(String id) {
    return materials.firstWhereOrNull((material) => material.id == id);
  }

  MaterialModel? getMaterialByName(name) {
    if (name != null && name != " " && name != "") {
      return materials.where((element) => (element.matName!.toLowerCase().contains(name.toLowerCase()))).firstOrNull;
    }
    return null;
  }

  void saveOrUpdateMaterial() async {
    // Validate the input before proceeding
    if (!materialFromHandler.validate()) return;
    // Create a material model based on the user input
    final updatedMaterialModel = _createMaterialModel();
    // Handle null material model
    if (updatedMaterialModel == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال الصلاحيات و البائع!');
      return;
    }
    // Prepare user change queue for saving
    final userChangeQueue = _prepareUserChangeQueue(updatedMaterialModel, ChangeType.addOrUpdate);

    // Save changes and handle results
    final changesResult = await _listenDataSourceRepository.saveAll(userChangeQueue);

    changesResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => _onSaveSuccess(updatedMaterialModel),
    );
  }

  void deleteMaterial() async {
    if (selectedMaterial == null) return;

    // Prepare user change queue for delete
    final userChangeQueue = _prepareUserChangeQueue(selectedMaterial!, ChangeType.remove);

    log('userChangeQueue length on deleteMaterial: ${userChangeQueue.length}');
    // Save changes and handle results
    final changesResult = await _listenDataSourceRepository.saveAll(userChangeQueue);

    changesResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => _onDeleteSuccess(),
    );
  }

  MaterialModel? _createMaterialModel() => _materialService.createMaterialModel(
        matVatGuid: materialFromHandler.selectedTax.value.taxGuid!,
        matGroupGuid: materialFromHandler.parentModel?.id ?? '',
        wholesalePrice: materialFromHandler.wholePriceController.text,
        retailPrice: materialFromHandler.retailPriceController.text,
        matName: materialFromHandler.nameController.text,
        matCode: materialFromHandler.codeController.text.toInt,
        matBarCode: materialFromHandler.barcodeController.text,
        endUserPrice: materialFromHandler.customerPriceController.text,
        matCurrencyVal: materialFromHandler.costPriceController.text.toDouble,
        materialModel: selectedMaterial,
      );

  List<ChangesModel> _prepareUserChangeQueue(MaterialModel materialModel, ChangeType changeType) => read<UserManagementController>()
      .nonLoggedInUsers
      .map(
        (user) => ChangesModel(
          targetUserId: user.userId!,
          changeItems: {
            ChangeCollection.materials: [
              ChangeItem(
                target: ChangeTarget(
                  targetCollection: ChangeCollection.materials,
                  changeType: changeType,
                ),
                change: materialModel.toJson(),
              )
            ]
          },
        ),
      )
      .toList();

  void _onSaveSuccess(MaterialModel materialModel) async {
    // Persist the data in Hive upon successful save
    final hiveResult = await _materialsHiveRepo.save(materialModel);

    hiveResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedMaterial) {
        log('materials length before add item: ${materials.length}');
        AppUIUtils.onSuccess('تم الحفظ بنجاح');
        reloadMaterials();
        log('materials length after add item: ${materials.length}');
      },
    );
  }

  void _onDeleteSuccess() async {
    final MaterialModel materialModel = selectedMaterial!;

    // Persist the data in Hive upon successful save
    final hiveResult = await _materialsHiveRepo.delete(materialModel, materialModel.id!);

    hiveResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedMaterial) {
        log('materials length before add item: ${materials.length}');
        AppUIUtils.onSuccess('تم الحفظ بنجاح');
        reloadMaterials();
        log('materials length after add item: ${materials.length}');
      },
    );
  }

  void navigateToAddOrUpdateMaterialScreen({String? matId}) {
    selectedMaterial = null;
    if (matId != null) selectedMaterial = getMaterialById(matId);
    materialFromHandler.init(selectedMaterial);
    to(AppRoutes.addMaterialScreen);
  }

  void openMaterialSelectionDialog({
    required String query,
    required BuildContext context,
  }) async {
    MaterialModel? searchedMaterial = await searchProductTextDialog(query);
    materialFromHandler.parentModel = searchedMaterial;
    update();
  }
}
