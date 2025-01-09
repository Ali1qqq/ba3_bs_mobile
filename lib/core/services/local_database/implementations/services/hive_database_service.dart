import 'package:ba3_bs_mobile/core/services/local_database/interfaces/i_local_database_service.dart';
import 'package:hive/hive.dart';

class HiveDatabaseService<T> implements ILocalDatabaseService<T> {
  final Box<T> _box;

  HiveDatabaseService(this._box);

  @override
  Future<void> insert(T data) async {
    if (data is HiveObject) {
      if (!data.isInBox) {
        await _box.add(data); // Add object to the box if it's not already in it
      }
      await data.save(); // Save the object to the box
    } else {
      throw Exception('Data must be a HiveObject');
    }
  }

  @override
  Future<void> insertAll(List<T> data) async {
    for (var item in data) {
      if (item is HiveObject) {
        if (!item.isInBox) {
          await _box.add(item); // Add each item to the box if it's not already in it
        }
        await item.save(); // Save the object
      }
    }
  }

  @override
  Future<List<T>> fetchAll() async {
    return _box.values.toList(); // Get all values from the box
  }

  @override
  Future<T?> fetchById(String id) async {
    return _box.get(id); // Fetch an item by its ID
  }

  @override
  Future<void> update(T data) async {
    if (data is HiveObject) {
      await data.save(); // Save the updated object
    } else {
      throw Exception('Data must be a HiveObject');
    }
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id); // Delete the item by ID
  }

  @override
  Future<void> clear() async {
    await _box.clear(); // Clear all data from the box
  }
}
