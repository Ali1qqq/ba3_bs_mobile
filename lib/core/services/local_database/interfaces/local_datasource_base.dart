import 'package:ba3_bs_mobile/core/services/local_database/interfaces/i_local_database_service.dart';

abstract class LocalDatasourceBase<T> {
  final ILocalDatabaseService<T> database;

  LocalDatasourceBase(this.database);

  Future<void> saveData(T data);

  Future<void> saveAllData(List<T> data);

  Future<List<T>> getAllData();

  Future<T?> getDataById(String id);

  Future<void> removeData(T item);

  Future<void> removeAllData(List<T> data);

  Future<void> clearAllData();
}
