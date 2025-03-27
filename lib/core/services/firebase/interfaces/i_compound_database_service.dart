import '../../../models/date_filter.dart';
import '../../../models/query_filter.dart';

abstract class ICompoundDatabaseService<T> {
  Future<T> add({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
    required T data,
    double? metaValue,
  });

  Future<List<T>> fetchAll({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
  });

  Future<List<Map<String, dynamic>>> fetchWhere<V>({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    required String? field,
    required V? value,
    DateFilter? dateFilter,
  });

  Future<T> fetchById({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
  });

  Future<void> update({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
    required T data,
  });

  Future<void> delete({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
    double? metaValue,
  });

  Future<int> countDocuments({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    QueryFilter? countQueryFilter,
  });

  Future<List<T>> addAll({
    required List<T> items,
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    double? metaValue,
  });

  Future<double?> fetchMetaData({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
  });
}
