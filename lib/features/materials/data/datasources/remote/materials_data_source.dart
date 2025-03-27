// MaterialsDataSource Implementation
import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';

import '../../../../../core/models/query_filter.dart';
import '../../../../../core/services/firebase/interfaces/queryable_savable_datasource.dart';
import '../../models/materials/material_model.dart';

class MaterialsRemoteDatasource extends QueryableSavableDatasource<MaterialModel> {
  MaterialsRemoteDatasource({required super.databaseService});

  @override
  String get path => ApiConstants.materials; // Collection name in Firestore

  @override
  Future<List<MaterialModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final materials = data.map((item) => MaterialModel.fromJson(item)).toList();

    return materials;
  }

  @override
  Future<MaterialModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return MaterialModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<MaterialModel> save(MaterialModel item) async {
    final data = await databaseService.add(path: path, documentId: item.id, data: item.toJson());

    return MaterialModel.fromJson(data);
  }

  @override
  Future<List<MaterialModel>> saveAll(List<MaterialModel> items) async {
    final savedData = await databaseService.addAll(
      path: path,
      data: items.map((item) => {...item.toJson(), 'docId': item.id}).toList(),
    );

    return savedData.map(MaterialModel.fromJson).toList();
  }

  @override
  Future<List<MaterialModel>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter}) async {
    final data = await databaseService.fetchWhere(path: path, queryFilters: queryFilters, dateFilter: dateFilter);

    final materials = data.map((item) => MaterialModel.fromJson(item)).toList();

    return materials;
  }
}