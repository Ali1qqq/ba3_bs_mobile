import 'i_remote_database_service.dart';

abstract class RemoteDatasourceBase<T> {
  final IRemoteDatabaseService<Map<String, dynamic>> databaseService;

  RemoteDatasourceBase({required this.databaseService});

  // Path getter to be overridden by subclasses
  String get path;

  Future<List<T>> fetchAll();

  Future<T> fetchById(String id);

  Future<void> delete(String id);

  Future<T> save(T item);
}
