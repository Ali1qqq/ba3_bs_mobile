import 'datasource_base.dart';

abstract class FetchWhereCapability<T> {
  Future<List<T>> fetchWhere<V>({required String field, required V value});
}

abstract class FilterableDatasource<T> extends DatasourceBase<T> implements FetchWhereCapability<T> {
  FilterableDatasource({required super.databaseService});

  @override
  Future<List<T>> fetchWhere<V>({required String field, required V value});
}
