import 'remote_datasource_base.dart';

abstract class SaveAllCapability<T> {
  Future<List<T>> saveAll(List<T> items);
}

abstract class BulkSavableDatasource<T> extends RemoteDatasourceBase<T> implements SaveAllCapability<T> {
  BulkSavableDatasource({required super.databaseService});
}
