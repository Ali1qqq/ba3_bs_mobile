// BillsDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/filterable_data_source.dart';

import '../models/user_model.dart';

class UsersDataSource extends FilterableDatasource<UserModel> {
  UsersDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.users; // Collection name in Firestore

  @override
  Future<List<UserModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final users = data.map((item) => UserModel.fromJson(item)).toList();

    return users;
  }

  @override
  Future<List<UserModel>> fetchWhere<V>({required String field, required V value}) async {
    final data = await databaseService.fetchWhere(path: path, field: field, value: value);

    final users = data.map((item) => UserModel.fromJson(item)).toList();

    return users;
  }

  @override
  Future<UserModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return UserModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<UserModel> save(UserModel item, [bool? save]) async {
    if (item.userId == null) {
      final data = await databaseService.add(path: path, documentId: item.userId, data: item.toJson());

      return UserModel.fromJson(data);
    } else {
      await databaseService.update(path: path, documentId: item.userId, data: item.toJson());
      return item;
    }
  }
}
