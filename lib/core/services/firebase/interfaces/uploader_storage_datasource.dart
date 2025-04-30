import 'filterable_datasource.dart';
import 'i_remote_storage_service.dart';
import 'remote_datasource_base.dart';

abstract class UploaderCapability<T> {
  Future<String> uploadImage(String imagePath);
}

abstract class UploaderStorageDataSource<T> extends RemoteDatasourceBase<T>
    implements UploaderCapability<T> {
  final IRemoteStorageService<String> databaseStorageService;

  UploaderStorageDataSource(
      {required super.databaseService, required this.databaseStorageService});
}

abstract class ImageLoaderUploaderCapability<T> {
  Future<String> uploadImage({required String imagePath});

  Future<String?> fetchImage(String docId);
}

abstract class ImageLoaderUploaderDataSource<T> extends RemoteDatasourceBase<T>
    implements ImageLoaderUploaderCapability<T>, FetchWhereCapability<T> {
  ImageLoaderUploaderDataSource({required super.databaseService});
}
