import 'bulk_savable_datasource.dart';
import 'remote_datasource_base.dart';
import 'filterable_datasource.dart';

abstract class QueryableSavableDatasource<T> extends RemoteDatasourceBase<T>
    implements FetchWhereCapability<T>, SaveAllCapability<T> {
  QueryableSavableDatasource({required super.databaseService});
}
