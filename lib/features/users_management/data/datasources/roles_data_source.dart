// BillsDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';

import '../../../../core/services/firebase/interfaces/remote_datasource_base.dart';

class RolesDataSource extends RemoteDatasourceBase<RoleModel> {
  RolesDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.roles; // Collection name in Firestore

  @override
  Future<List<RoleModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final entryBonds = data.map((item) => RoleModel.fromJson(item)).toList();

    return entryBonds;
  }

  @override
  Future<RoleModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return RoleModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<RoleModel> save(RoleModel item) async {
    final data = await databaseService.add(path: path, documentId: item.roleId, data: item.toJson());

    return RoleModel.fromJson(data);
  }
}
