import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/remote_datasource_base.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';

class UserLeaveRequestsRemoteDatasource
    extends RemoteDatasourceBase<UserModel> {
  UserLeaveRequestsRemoteDatasource({
    required super.databaseService,
  });

  @override
  String get path => ApiConstants.users;

  @override
  Future<List<UserModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    return data.map((e) => UserModel.fromJson(e)).toList();
  }

  @override
  Future<UserModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);

    return UserModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(
      path: path,
      documentId: id,
    );
  }

  @override
  Future<UserModel> save(UserModel item) async {
    final data = await databaseService.add(
      path: path,
      documentId: item.userId,
      data: item.toJson(),
    );

    return UserModel.fromJson(data);
  }
}
