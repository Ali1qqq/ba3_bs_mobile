// MaterialsDataSource Implementation
import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_group.dart';

import '../../../../../core/models/query_filter.dart';
import '../../../../../core/services/firebase/interfaces/queryable_savable_datasource.dart';

class MaterialsGroupsDataSource extends QueryableSavableDatasource<MaterialGroupModel> {
  MaterialsGroupsDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.materialGroup; // Collection name in Firestore

  @override
  Future<List<MaterialGroupModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final sellers = data.map((item) => MaterialGroupModel.fromJson(item)).toList();

    return sellers;
  }

  @override
  Future<MaterialGroupModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return MaterialGroupModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<MaterialGroupModel> save(MaterialGroupModel item) async {
    final data = await databaseService.add(path: path, documentId: item.matGroupGuid, data: item.toJson());

    return MaterialGroupModel.fromJson(data);
  }

  @override
  Future<List<MaterialGroupModel>> saveAll(List<MaterialGroupModel> items) async {
    final savedData = await databaseService.addAll(
      path: path,
      data: items.map((item) => {...item.toJson(), 'docId': item.matGroupGuid}).toList(),
    );

    return savedData.map(MaterialGroupModel.fromJson).toList();
  }

  @override
  Future<List<MaterialGroupModel>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter}) async {
    final data = await databaseService.fetchWhere(path: path, queryFilters: queryFilters);

    final materials = data.map((item) => MaterialGroupModel.fromJson(item)).toList();

    return materials;
  }
}