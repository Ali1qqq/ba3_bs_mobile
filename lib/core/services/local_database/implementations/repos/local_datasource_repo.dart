import 'dart:developer';

import '../../../firebase/interfaces/remote_datasource_base.dart';
import '../../interfaces/local_datasource_base.dart';

class LocalDatasourceRepository<T> {
  final LocalDatasourceBase<T> localDatasource;
  final RemoteDatasourceBase<T> remoteDatasource;

  LocalDatasourceRepository({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  Future<List<T>> getAll() async {
    log('getAll');
    final localData = await localDatasource.getAllData();
    if (localData.isNotEmpty) {
      log('localData ${localData.length}');
      return localData;
    }

    // Fetch from remote if local is empty
    final remoteData = await remoteDatasource.fetchAll();
    await localDatasource.saveAllData(remoteData);
    log('remoteData ${remoteData.length}');

    return remoteData;
  }

  Future<T?> getById(String id) async {
    final localData = await localDatasource.getDataById(id);
    if (localData != null) {
      return localData;
    }

    // Fetch from remote if not found locally
    final remoteData = await remoteDatasource.fetchById(id);
    if (remoteData != null) {
      await localDatasource.saveData(remoteData);
    }
    return remoteData;
  }

  Future<void> save(T data) async {
    await localDatasource.saveData(data);
  }

  Future<void> saveAll(List<T> data) async {
    await localDatasource.saveAllData(data);
  }

  Future<void> delete(String id) async {
    await localDatasource.removeData(id);
  }

  Future<void> clear() async {
    await localDatasource.clearAllData();
  }
}
