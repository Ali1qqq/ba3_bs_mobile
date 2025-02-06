import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import 'package:ba3_bs_mobile/core/services/json_file_operations/interfaces/import/i_import_repository.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_group.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/services/firestore_uploader.dart';
import '../../../core/utils/app_service_utils.dart';
import '../../../core/utils/app_ui_utils.dart';

class MaterialGroupController extends GetxController with AppNavigator {
  final IImportRepository<MaterialGroupModel> _importRepository;

  final RemoteDataSourceRepository<MaterialGroupModel> _dataSourceRepository;

  MaterialGroupController(this._importRepository, this._dataSourceRepository);

  List<MaterialGroupModel> materialGroups = [];

  bool isLoading = false;

  getAllGroups() async {
    final result = await _dataSourceRepository.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedMaterialGroupGroup) => materialGroups.assignAll(fetchedMaterialGroupGroup),
    );
  }

  @override
  void onInit() {
    super.onInit();

    getAllGroups();

    log('MaterialGroupController onInit');
  }

  void navigateToAllMaterialScreen() {
    to(AppRoutes.showAllMaterialsGroupScreen);
  }

  Future<void> fetchAllMaterialGroupGroupFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = await _importRepository.importXmlFile(file);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedMaterialGroupGroup) => _handelFetchAllMaterialGroupGroupFromLocalSuccess(fetchedMaterialGroupGroup),
      );
    }
  }

  Future<List<MaterialGroupModel>> searchOfProductByText(query) async {
    List<MaterialGroupModel> searchedMaterialGroups = [];

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

    searchedMaterialGroups = materialGroups.where((item) {
      bool prodName = item.groupName.toString().toLowerCase().contains(query3.toLowerCase()) &&
          item.groupName.toString().toLowerCase().contains(query2.toLowerCase());
      bool prodCode = item.groupCode.toString().toLowerCase().contains(query.toLowerCase());
      return (prodName || prodCode);
    }).toList();

    return searchedMaterialGroups;
  }

  void _handelFetchAllMaterialGroupGroupFromLocalSuccess(
      List<MaterialGroupModel> fetchedMaterialGroupGroupFromNetwork) async {
    final fetchedMaterialGroup = fetchedMaterialGroupGroupFromNetwork;
    log('fetchedMaterialGroup length ${fetchedMaterialGroup.length}');

    materialGroups.addAll(fetchedMaterialGroup);

    // Show progress in the UI
    FirestoreUploader firestoreUploader = FirestoreUploader();
    await firestoreUploader.sequentially(
      data: materialGroups.map((item) => {...item.toJson(), 'docId': item.matGroupGuid}).toList(),
      collectionPath: ApiConstants.materialGroup,
      onProgress: (progress) {
        log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      },
    );
  }

  MaterialGroupModel? getMaterialGroupById(String? id) {
    if (id == null || id == '') return null;
    return materialGroups.firstWhereOrNull(
          (matGroup) => matGroup.matGroupGuid == id,
        ) ??
        MaterialGroupModel(
            matGroupGuid: id,
            groupCode: id,
            groupName: id,
            groupLatinName: id,
            parentGuid: id,
            groupNotes: id,
            groupSecurity: 0,
            groupType: 0,
            groupVat: 0,
            groupNumber: 0,
            groupBranchMask: 0);
  }
}
