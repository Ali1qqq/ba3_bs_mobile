import '../../../../core/network/api_constants.dart';
import '../../../../core/services/firebase/interfaces/remote_datasource_base.dart';
import '../models/log_model.dart';

class LogDataSource extends RemoteDatasourceBase<LogModel> {
  LogDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.logs;

  @override
  Future<List<LogModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);
    return data.map((item) => LogModel.fromJson(item)).toList();
  }

  @override
  Future<LogModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return LogModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<LogModel> save(LogModel item) async {
    final data = await databaseService.add(path: path, documentId: item.id, data: item.toJson());
    return LogModel.fromJson(data);
  }
}
