abstract class ILocalDatabaseService<T> {
  Future<void> insert(String id, T data);

  Future<void> insertAll(Map<String, T> data);

  Future<List<T>> fetchAll();

  T? fetchById(String id);

  Future<void> update(String id, T data);

  Future<void> updateAll(Map<String, T> data);

  Future<void> delete(String id);

  Future<void> deleteAll(List<String> ids);

  Future<void> clear();
}
