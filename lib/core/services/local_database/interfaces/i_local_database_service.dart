abstract class ILocalDatabaseService<T> {
  Future<void> insert(T data);

  Future<void> insertAll(List<T> data);

  Future<List<T>> fetchAll();

  Future<T?> fetchById(String id);

  Future<void> update(T data);

  Future<void> delete(String id);

  Future<void> clear();
}
