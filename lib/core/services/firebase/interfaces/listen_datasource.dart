import 'package:ba3_bs_mobile/core/services/firebase/interfaces/remote_datasource_base.dart';

/// Abstract class for ListenCapability
abstract class ListenCapability<T> {
  /// Abstract method for listening to changes in a collection
  Stream<T> subscribeToDoc({required String documentId});
}

/// Implementation of ListenDatasource
abstract class ListenableDatasource<T> extends RemoteDatasourceBase<T> implements ListenCapability<T> {
  ListenableDatasource({required super.databaseService});
}
