import 'package:ba3_bs_mobile/core/services/local_database/interfaces/i_local_database_service.dart';

abstract class LocalDatasourceBase<T> {
  final ILocalDatabaseService<T> database;

  LocalDatasourceBase(this.database);

  Future<void> saveData(T item);

  Future<void> saveAllData(List<T> items);

  Future<List<T>> getAllData();

  T? getDataById(String id);

  Future<void> updateData(T item);

  Future<void> updateAllData(List<T> items);

  Future<void> removeData(T item);

  Future<void> removeAllData(List<T> items);

  Future<void> clearAllData();
}