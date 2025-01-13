import '../../../models/date_filter.dart';
import '../../../models/query_filter.dart';

abstract class IRemoteDatabaseService<T> {
  /// Fetches all items of type [T] from the specified [path].
  Future<List<T>> fetchAll({required String path});

  /// Fetches a list of items of type [T] from the specified [path] where the field [field]
  /// matches the value [value] of type [V].
  Future<List<T>> fetchWhere({required String path, required List<QueryFilter> queryFilters, DateFilter? dateFilter});

  /// Fetches a single item of type [T] from the specified [path] by its [documentId].
  Future<T> fetchById({required String path, String? documentId});

  Stream<T> subscribeToDoc({required String path, String? documentId});

  /// Deletes an item from the specified [path] by its [documentId].
  Future<void> delete({required String path, String? documentId, String? mapFieldName});

  /// Adds a new item of type [T] to the specified [path] with the given [data].
  Future<T> add({required String path, String? documentId, required Map<String, dynamic> data});

  /// Updates an item of type [T] in the specified [path] by its [documentId] with the given [data].
  Future<void> update({required String path, String? documentId, required Map<String, dynamic> data});

  /// Adds multiple items to the specified [path] using a batch write and returns the added items.
  Future<List<Map<String, dynamic>>> addAll({
    required String path,
    required List<Map<String, dynamic>> data,
  });

  /// Updates multiple documents in the Firestore collection at [path] using batch operations
  /// and returns a list of the processed items.
  ///
  /// For each item in [items]:
  /// - If the document (identified by [docIdField]) does not exist, it creates it with [nestedFieldPath].
  /// - If the document exists, it updates [nestedFieldPath] using `FieldValue.arrayUnion`.
  Future<List<Map<String, dynamic>>> batchUpdateWithArrayUnion({
    required String path,
    required List<Map<String, dynamic>> items,
    required String docIdField,
    required String nestedFieldPath,
  });
}
