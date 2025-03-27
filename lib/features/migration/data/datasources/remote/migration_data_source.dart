// MigrationDataSource Implementation

import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/remote_datasource_base.dart';

import '../../models/migration_model.dart';

class MigrationRemoteDatasource extends RemoteDatasourceBase<MigrationModel> {
  MigrationRemoteDatasource({required super.databaseService});

  @override
  String get path => ApiConstants.migration; // Collection name in Firestore

  @override
  Future<List<MigrationModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final materials = data.map((item) => MigrationModel.fromJson(item)).toList();

    return materials;
  }

  @override
  Future<MigrationModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return MigrationModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<MigrationModel> save(MigrationModel item) async {
    final data = await databaseService.add(path: path, documentId: item.id, data: item.toJson());

    return MigrationModel.fromJson(data);
  }
}