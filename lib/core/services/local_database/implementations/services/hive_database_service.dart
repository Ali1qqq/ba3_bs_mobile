import 'package:ba3_bs_mobile/core/services/local_database/interfaces/i_local_database_service.dart';
import 'package:hive/hive.dart';

class HiveDatabaseService<T> implements ILocalDatabaseService<T> {
  final Box<T> _box;

  HiveDatabaseService(this._box);

  @override
  Future<void> insert(T data) async {
    if (data is HiveObject) {
      await data.save();
    } else {
      throw Exception('Data must be a HiveObject');
    }
  }

  @override
  Future<void> insertAll(List<T> data) async {
    for (var item in data) {
      await insert(item);
    }
  }

  @override
  Future<List<T>> fetchAll() async {
    return _box.values.toList();
  }

  @override
  Future<T?> fetchById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> update(T data) async {
    if (data is HiveObject) {
      await data.save();
    } else {
      throw Exception('Data must be a HiveObject');
    }
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
