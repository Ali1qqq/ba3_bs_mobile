import 'package:ba3_bs_mobile/core/services/firebase/interfaces/uploader_storage_datasource.dart';

import 'filterable_datasource.dart';
import 'remote_datasource_base.dart';

abstract class UploaderStorageQueryableDatasource<T> extends RemoteDatasourceBase<T>
    implements UploaderCapability<T>, FetchWhereCapability<T> {
  // final IRemoteStorageService<String> databaseStorageService;
  //
  // UploaderStorageQueryableDatasource({required super.databaseService, required this.databaseStorageService});

  UploaderStorageQueryableDatasource({required super.databaseService});
}