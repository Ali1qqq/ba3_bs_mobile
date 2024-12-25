import 'datasource_base.dart';

abstract class SaveAllCapability<T> {
  Future<List<T>> saveAll(List<T> items);
}

abstract class DatasourceWithSaveAll<T> extends DatasourceBase<T> implements SaveAllCapability<T> {
  DatasourceWithSaveAll({required super.databaseService});

  @override
  Future<List<T>> saveAll(List<T> items);
}
