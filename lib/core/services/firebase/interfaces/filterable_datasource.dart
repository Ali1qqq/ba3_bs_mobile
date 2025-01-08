import '../../../models/date_filter.dart';
import '../../../models/query_filter.dart';
import 'remote_datasource_base.dart';

abstract class FetchWhereCapability<T> {
  Future<List<T>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter});
}

abstract class FilterableDatasource<T> extends RemoteDatasourceBase<T> implements FetchWhereCapability<T> {
  FilterableDatasource({required super.databaseService});
}
