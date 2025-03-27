import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/dialogs/search_material_group_text_dialog.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/encode_decode_text.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs_mobile/core/services/json_file_operations/implementations/import_export_repo.dart';
import 'package:ba3_bs_mobile/core/services/local_database/implementations/repos/local_datasource_repo.dart';
import 'package:ba3_bs_mobile/features/changes/data/model/changes_model.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_group_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_group.dart';
import 'package:ba3_bs_mobile/features/materials/service/material_from_handler.dart';
import 'package:ba3_bs_mobile/features/materials/service/material_service.dart';
import 'package:ba3_bs_mobile/features/materials/ui/screens/all_materials_screen.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/services/firebase/implementations/repos/listen_datasource_repo.dart';
import '../../../core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import '../../../core/services/firebase/implementations/services/firestore_uploader.dart';
import '../../../core/utils/app_service_utils.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/materials/material_model.dart';
import '../ui/screens/add_material_screen.dart';

class MaterialController extends GetxController with AppNavigator, FloatingLauncher {
  final ImportExportRepository<MaterialModel> _jsonImportExportRepo;
  final LocalDatasourceRepository<MaterialModel> _materialsHiveRepo;

  final QueryableSavableRepository<MaterialModel> _materialRemoteRepo;
  final ListenDataSourceRepository<ChangesModel> _listenDataSourceRepository;

  MaterialController(this._jsonImportExportRepo, this._materialsHiveRepo, this._listenDataSourceRepository, this._materialRemoteRepo);

  List<MaterialModel> materials = [];
  List<MaterialModel> materialsForShow = [];

  // Map<String, List<MaterialModel>> get productsGrouped => materials.groupBy((product) => product.matGroupGuid!);
  Map<String, List<MaterialModel>> productsGrouped = {};

  MaterialModel? selectedMaterial;

  late MaterialFromHandler materialFromHandler;
  late MaterialService _materialService;

  bool get isFromHandler => selectedMaterial == null ? false : true;
  final logger = Logger();

  @override
  onInit() {
    super.onInit();
    _initializer();
  }

  _initializer() {
    materialFromHandler = MaterialFromHandler();
    _materialService = MaterialService();

    read<MaterialGroupController>();
    reloadMaterials();
  }

  bool isLoading = false;

  Rx<RequestState> saveAllMaterialsRequestState = RequestState.initial.obs;

  Future<void> fetchMaterials() async {
    final result = await _materialsHiveRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedMaterial) {
        materials.assignAll(fetchedMaterial);
        productsGrouped = fetchedMaterial.groupBy((product) => product.matGroupGuid!);
      },
    );
  }

  Future<void> fetchMaterialsGroup({String? groupGuid}) async {
    if (groupGuid != null) {
      materialsForShow.assignAll(productsGrouped[groupGuid]!);
    } else {
      materialsForShow.assignAll(materials);
    }
  }

  Future<void> reloadMaterials() async {
    await fetchMaterials();
  }

  Future<void> saveAllMaterialOnLocal(List<MaterialModel> materialsToSave) async {
    final result = await _materialsHiveRepo.saveAll(materialsToSave);

    result.fold((failure) => AppUIUtils.onFailure(failure.message), (savedMaterials) {
      log('materials length before add item: ${materials.length}');

      AppUIUtils.onSuccess('تم الحفظ بنجاح');
      reloadMaterials();

      log('materials length after add item: ${materials.length}');
    });
  }

  Future<void> updateAllMaterial(List<MaterialModel> materialsToSave) async {
    final result = await _materialsHiveRepo.updateAll(materialsToSave);
    result.fold((failure) => AppUIUtils.onFailure(failure.message), (savedMaterials) {
      log('materials length before update item: ${materials.length}');
      AppUIUtils.onSuccess('تم الحفظ بنجاح');
      reloadMaterials();
      log('materials length update add item: ${materials.length}');
    });
  }

  Future<void> deleteAllMaterial(List<MaterialModel> materialsToDelete) async {
    // Filter materials that match the IDs in materialsToDelete
    final copiedMaterials = materials.where((material) => materialsToDelete.any((e) => e.id == material.id)).toList();

    // Attempt to delete all matched materials
    final result = await _materialsHiveRepo.deleteAll(copiedMaterials);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => reloadMaterials(), // Refresh state after successful deletion
    );
  }

  Future<void> fetchAllMaterialFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = await _jsonImportExportRepo.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedMaterial) => _handelFetchAllMaterialFromLocalSuccess(fetchedMaterial),
      );
    }
  }

  Future<void> deleteAllMaterialFromLocal() async {
    final result = await _materialsHiveRepo.clear();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => AppUIUtils.onSuccess('تم حذف المواد بنجاح'),
    );
  }

  // Initialize a progress observable
  RxDouble uploadProgress = 0.0.obs;

  void _handelFetchAllMaterialFromLocalSuccess(List<MaterialModel> fetchedMaterial) async {
    saveAllMaterialsRequestState.value = RequestState.loading;

    log("fetchedMaterial length ${fetchedMaterial.length}");
    log('current Materials length is ${materials.length}');

    final newMaterials = fetchedMaterial.subtract(materials, (mat) => mat.matName);
    log('newMaterials length is ${newMaterials.length}');

    if (newMaterials.isNotEmpty) {
      // Show progress in the UI
      FirestoreUploader firestoreUploader = FirestoreUploader();

      await firestoreUploader.sequentially(
        data: newMaterials.map((item) => {...item.toJson(), 'docId': item.id}).toList(),
        collectionPath: ApiConstants.materials,
        onProgress: (progress) {
          uploadProgress.value = progress; // Update progress
          log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );
      for (final materialModel in newMaterials) {
        if (materialModel.id == newMaterials.last.id) {
          _onSaveSuccess(materialModel, changeType: ChangeType.add, withReloadMaterial: true);
        } else {
          _onSaveSuccess(materialModel, changeType: ChangeType.add, withReloadMaterial: false);
        }
      }
    }

    saveAllMaterialsRequestState.value = RequestState.success;
    materials.assignAll(fetchedMaterial);
  }

  void navigateToAllMaterialScreen({String? groupGuid, required BuildContext context}) {
    // reloadMaterials();
    fetchMaterialsGroup(groupGuid: groupGuid);

    launchFloatingWindow(context: context, minimizedTitle: ApiConstants.materials.tr, floatingScreen: AllMaterialsScreen());

    // to(AppRoutes.showAllMaterialsScreen);
  }

  List<MaterialModel> searchOfProductByText(String query) {
    if (materials.isEmpty) {
      log('Materials list is empty');
    }

    query = AppServiceUtils.replaceArabicNumbersWithEnglish(query);
    String lowerQuery = query.toLowerCase().trim();

    List<String> searchParts = lowerQuery.split(RegExp(r'\s+'));

    // Check for exact match first
    var exactMatch = materials.where(
      (item) =>
          item.matName!.toLowerCase() == lowerQuery ||
          item.matCode!.toString().toLowerCase() == lowerQuery ||
          (item.matBarCode != null && item.matBarCode!.toLowerCase() == lowerQuery) ||
          (item.serialNumbers != null &&
              item.serialNumbers!.entries
                  .any((entry) => entry.key.toLowerCase() == lowerQuery && entry.value == false)), // Only allow unsold serials
    );

    if (exactMatch.length == 1) {
      return [exactMatch.first];
    } else if (exactMatch.length > 1) {
      return exactMatch.toList();
    }

    // Check for matches where name, code, barcode, or serial numbers start with the query
    var startsWithMatches = materials
        .where(
          (item) =>
              searchParts.every((part) => item.matName!.toLowerCase().startsWith(part)) ||
              searchParts.every((part) => item.matCode.toString().toLowerCase().startsWith(part)) ||
              (item.matBarCode != null && searchParts.every((part) => item.matBarCode!.toLowerCase().startsWith(part))) ||
              (item.serialNumbers != null &&
                  searchParts.every(
                    (part) => item.serialNumbers!.entries.any(
                      // Only allow unsold serials
                      (entry) => entry.key.toLowerCase().startsWith(part) && entry.value == false,
                    ),
                  )),
        )
        .toList();

    if (startsWithMatches.isNotEmpty) {
      return startsWithMatches;
    }

    // Check for matches where name, code, barcode, or serial numbers contain the query
    return materials
        .where(
          (item) =>
              searchParts.every((part) => item.matName.toString().toLowerCase().contains(part)) ||
              searchParts.every((part) => item.matCode.toString().toLowerCase().contains(part)) ||
              (item.matBarCode != null && searchParts.every((part) => item.matBarCode!.toLowerCase().contains(part))) ||
              (item.serialNumbers != null &&
                  searchParts.every(
                    (part) => item.serialNumbers!.entries.any((entry) => entry.key.toLowerCase().contains(part) && entry.value == false),
                  )), // Only allow unsold serials
        )
        .toList();
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

  double getMaterialMinPriceById(String id) {
    double price = materials.firstWhereOrNull((material) => material.id == id)?.calcMinPrice ?? 0.0;

    return price.isNaN || price.isInfinite ? 0.0 : price;
  }

  bool doesMaterialExist(String? materialName) {
    if (materialName == null) return false;
    return materials.any((material) => material.matName?.trim() == materialName.trim());
  }

  MaterialModel? getMaterialByName(name) {
    // log('name $name');
    // log(materials.where((element) => (element.matName!.toLowerCase().contains(name.toLowerCase()))).firstOrNull.toString());
    if (name != null && name != " " && name != "") {
      return materials.where((element) => (element.matName == name)).firstOrNull;
    }
    return null;
  }

  MaterialModel? searchMaterialByName(String? name) {
    if (name != null && name != " " && name != "") {
      // log('name $name');
      // log(name.encodeProblematic().encodeProblematic());
      // log(materials.where((element) {
      //   // log(element.matName!);
      //   return (element.matName==name.encodeProblematic().encodeProblematic());
      // }).map((e) => e.matName!).toString());

      return materials
          .where((element) => (element.matName! == name.encodeProblematic().encodeProblematic() ||
              element.matName! == name ||
              element.matName!.decodeProblematic().decodeProblematic() == name ||
              element.matName!.removeAllWhitespace == name.removeAllWhitespace))
          .firstOrNull;
    }
    return null;
  }

  Future<void> saveMaterialsOnRemote(List<MaterialModel> materials) async {
    final result = await _materialRemoteRepo.saveAll(materials);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedMaterial) {},
    );
  }

  Future<void> saveOrUpdateMaterial() async {
    // Validate the input before proceeding

    if (!materialFromHandler.validate()) return;
    // Create a material model based on the user input
    final materialModel = _createMaterialModel();
    // Handle null material model
    if (materialModel == null) {
      AppUIUtils.onFailure('من فضلك قم!');
      return;
    }

    final hiveResult =
        materialModel.id != null ? await _materialsHiveRepo.update(materialModel) : await _materialsHiveRepo.save(materialModel);

    hiveResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedMaterial) {
        _onSaveSuccess(savedMaterial, changeType: selectedMaterial != null ? ChangeType.update : ChangeType.add);
      },
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
        matGroupGuid: materialFromHandler.parentModel?.matGroupGuid ?? '',
        wholesalePrice: materialFromHandler.wholePriceController.text,
        retailPrice: materialFromHandler.retailPriceController.text,
        matName: materialFromHandler.nameController.text,
        matCode: materialFromHandler.codeController.text.toInt,
        matBarCode: materialFromHandler.barcodeController.text,
        endUserPrice: materialFromHandler.customerPriceController.text,
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

  Future<void> updateMaterialWithChanges(MaterialModel updatedMaterialModel) async {
    final hiveResult = await _materialsHiveRepo.update(updatedMaterialModel);

    hiveResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedMaterial) => _onSaveSuccess(updatedMaterialModel, changeType: ChangeType.update),
    );
  }

  Future<void> updateMaterial(MaterialModel updatedMaterialModel) async {
    final hiveResult = await _materialsHiveRepo.update(updatedMaterialModel);

    hiveResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedMaterial) => {},
    );
  }

  void _onSaveSuccess(MaterialModel materialModel, {required ChangeType changeType, bool withReloadMaterial = true}) async {
    if (withReloadMaterial) reloadMaterials();

    // Prepare user change queue for saving
    final userChangeQueue = _prepareUserChangeQueue(materialModel, changeType);

    // Save changes and handle  results
    final changesResult = await _listenDataSourceRepository.saveAll(userChangeQueue);

    changesResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) {},
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
        AppUIUtils.onSuccess('تم الحذف بنجاح');
        reloadMaterials();
        log('materials length after add item: ${materials.length}');
      },
    );
  }

  void navigateToAddOrUpdateMaterialScreen({String? matId, required BuildContext context}) {
    selectedMaterial = null;
    if (matId != null) selectedMaterial = getMaterialById(matId);

    materialFromHandler.init(selectedMaterial);
    launchFloatingWindow(context: context, minimizedTitle: ApiConstants.materials.tr, floatingScreen: AddMaterialScreen());
    // to(AppRoutes.addMaterialScreen);
  }

  void openMaterialGroupSelectionDialog({
    required String query,
    required BuildContext context,
  }) async {
    MaterialGroupModel? searchedMaterial = await searchProductGroupTextDialog(query, context);

    if (searchedMaterial != null) {
      materialFromHandler.parentModel = searchedMaterial;
      materialFromHandler.parentController.text = searchedMaterial.groupName.toString();
    } else {
      AppUIUtils.onFailure('لم يتم العثور على المجموعة');
    }
    update();
  }

  /// Updates a material's data using a provided update function.
  /// This function finds the material by `matId`, applies `updateFn` to modify it,
  /// and then saves the updated material.
  Future<void> updateAndSaveMaterial(String matId, MaterialModel Function(MaterialModel) updateFn) async {
    final materialModel = materials.firstWhere((material) => material.id == matId);
    // materialFromHandler.init();
    await updateMaterial(updateFn(materialModel));
    // await saveOrUpdateMaterial();
  }

  Future<void> updateMaterialByModel(MaterialModel materialModel, MaterialModel Function(MaterialModel) updateFn) async {
    await updateMaterial(updateFn(materialModel));
  }

  resetMaterialQuantityAndPrice() async {
    for (final material in materials.where(
      (element) => element.matQuantity != 0 || element.calcMinPrice != 0,
    )) {
      await updateMaterialByModel(
        material,
        (materialUpdate) => materialUpdate.copyWith(matQuantity: 0, calcMinPrice: 0),
      );
    }
    log("Finished");
  }

  /// Increases the quantity of a material by a given amount.
  /// Uses `updateMaterial` to modify `matQuantity`.
  Future<void> updateMaterialQuantity(String matId, int quantity) async {
    await updateAndSaveMaterial(
      matId,
      (material) => material.copyWith(
        matQuantity: (material.matQuantity ?? 0) + quantity,
      ),
    );
  }

  /// Sets the quantity of a material to a specific value.
  /// Unlike `updateMaterialQuantity`, this function replaces the quantity instead of adding to it.
  Future<void> setMaterialQuantity(String matId, int quantity) async {
    await updateAndSaveMaterial(matId, (material) => material.copyWith(matQuantity: quantity));
  }

  /// Updates both the quantity and minimum price of a material.
  /// The new price is calculated based on previous price and quantity using `_calcMinPrice`.
  Future<void> updateMaterialQuantityAndPrice({
    required String matId,
    required int quantity,
    required double priceInStatement,
    required int quantityInStatement,
  }) async {
    await updateAndSaveMaterial(
      matId,
      (material) => material.copyWith(
        matQuantity: (material.matQuantity ?? 0) + quantity,
        calcMinPrice: _calcMinPrice(
          oldMinPrice: material.calcMinPrice ?? 0,
          oldQuantity: material.matQuantity ?? 0,
          priceInStatement: priceInStatement,
          quantityInStatement: quantityInStatement,
        ),
      ),
    );
  }

  /// Updates the material's quantity and minimum price when a bill is deleted.
  /// This function sets a new quantity and applies a given minimum price.
  Future<void> updateMaterialQuantityAndPriceWhenDeleteBill({
    required String matId,
    required int quantity,
    required double currentMinPrice,
    required double lastEnterPrice,
  }) async {
    await updateAndSaveMaterial(
      matId,
      (material) => material.copyWith(
        matQuantity: quantity,
        calcMinPrice: currentMinPrice,
        matLastPriceCurVal: lastEnterPrice,
      ),
    );
  }

  /// Calculates the new minimum price after adding a new statement.
  /// Uses the weighted average formula:
  /// (old price * old quantity) + (new price * new quantity) / total quantity.
  /// If `totalQuantity` is 0, it avoids division by zero by returning 0.0.
  double _calcMinPrice({
    required double oldMinPrice,
    required int oldQuantity,
    required double priceInStatement,
    required int quantityInStatement,
  }) {
    int totalQuantity = oldQuantity + quantityInStatement;
    return totalQuantity > 0 ? ((oldMinPrice * oldQuantity) + (priceInStatement * quantityInStatement)) / totalQuantity : 0.0;
  }

  Future<void> updateAllMaterialWithDecodeProblematic() async {
    int i = 0;
    log('material length ${materials.length}');
    for (var mat in materials) {
      materialFromHandler.init(mat.copyWith(matName: mat.matName!.encodeProblematic()));
      await saveOrUpdateMaterial();
      log('mat number ${++i}');
    }
  }
}