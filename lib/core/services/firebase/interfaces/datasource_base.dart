import 'i_database_service.dart';

abstract class DatasourceBase<T> {
  final IDatabaseService<Map<String, dynamic>> databaseService;

  DatasourceBase({required this.databaseService});

  // Path getter to be overridden by subclasses
  String get path;

  Future<List<T>> fetchAll();

  Future<T> fetchById(String id);

  Future<void> delete(String id);

  Future<T> save(T item);
}
