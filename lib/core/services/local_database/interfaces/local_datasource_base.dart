import 'package:ba3_bs_mobile/core/services/local_database/interfaces/i_local_database_service.dart';

abstract class LocalDatasourceBase<T> {
  final ILocalDatabaseService<T> database;

  LocalDatasourceBase(this.database);

  Future<void> saveData(T data) => database.insert(data);

  Future<void> saveAllData(List<T> data) => database.insertAll(data);

  Future<List<T>> getAllData() => database.fetchAll();

  Future<T?> getDataById(String id) => database.fetchById(id);

  Future<void> removeData(String id) => database.delete(id);

  Future<void> clearAllData() => database.clear();
}
