// UserTaskDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';

import '../../../../core/models/date_filter.dart';
import '../../../../core/models/query_filter.dart';
import '../../../../core/services/firebase/interfaces/uploader_storage_queryable_datasource.dart';
import '../model/user_task_model.dart';

class UserTaskDataSource extends UploaderStorageQueryableDatasource<UserTaskModel> {
  // UserTaskDataSource({required super.databaseService, required super.databaseStorageService});

  UserTaskDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.userTask; // Collection name in Firestore

  @override
  Future<List<UserTaskModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final userTask = data.map((item) => UserTaskModel.fromJson(item)).toList();

    return userTask;
  }

  @override
  Future<List<UserTaskModel>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter}) async {
    final data = await databaseService.fetchWhere(path: path, queryFilters: queryFilters);

    final userTask = data.map((item) => UserTaskModel.fromJson(item)).toList();

    return userTask;
  }

  @override
  Future<UserTaskModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return UserTaskModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<UserTaskModel> save(UserTaskModel item) async {
    final data = await databaseService.add(path: path, documentId: item.docId, data: item.toJson());

    return UserTaskModel.fromJson(data);
  }

  @override
  Future<String> uploadImage(String imagePath) async {
    // final data = await databaseStorageService.uploadImage(imagePath: imagePath, path: path);
    //
    // return data;

    return '';
  }
}