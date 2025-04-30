import 'package:hive/hive.dart';

import '../../interfaces/i_local_database_service.dart';

class HiveDatabaseService<T> implements ILocalDatabaseService<T> {
  final Box<T> _box;

  HiveDatabaseService(this._box);

  @override
  Future<void> insert(String id, T data) async {
    await _box.put(id, data); // Insert or update the object with the given ID
  }

  @override
  Future<void> insertAll(Map<String, T> data) async {
    await _box
        .putAll(data); // Insert multiple objects with their respective IDs
  }

  @override
  Future<List<T>> fetchAll() async {
    return _box.values.toList(); // Retrieve all objects
  }

  @override
  T? fetchById(String id) {
    return _box.get(id); // Fetch a specific object by ID
  }

  @override
  Future<void> update(String id, T data) async {
    await _box.put(id, data); // Update the existing object
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id); // Delete an object by ID
  }

  @override
  Future<void> deleteAll(List<String> ids) async {
    await _box.deleteAll(ids); // Delete multiple objects by their IDs
  }

  @override
  Future<void> clear() async {
    await _box.clear(); // Clear all data
  }

  @override
  Future<void> updateAll(Map<String, T> data) async {
    await _box.putAll(data); // Update multiple objects at once
  }
}
