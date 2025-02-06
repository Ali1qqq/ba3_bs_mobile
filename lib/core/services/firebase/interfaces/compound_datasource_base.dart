import '../../../models/date_filter.dart';
import '../../../models/query_filter.dart';
import '../implementations/services/firestore_path_helper.dart';
import '../implementations/services/firestore_sequential_numbers.dart';
import 'i_compound_database_service.dart';

abstract class CompoundDatasourceBase<T, I> with FirestorePathHelper<I>, FirestoreSequentialNumbers {
  final ICompoundDatabaseService<Map<String, dynamic>> compoundDatabaseService;

  CompoundDatasourceBase({required this.compoundDatabaseService});

  // Path getter to be overridden by subclasses
  String get rootCollectionPath;

  Future<List<T>> fetchAll({required I itemIdentifier});

  Future<Map<I, List<T>>> fetchAllNested({required List<I> itemIdentifiers});

  Future<List<T>> fetchWhere<V>({
    required I itemIdentifier,
    required String field,
    required V value,
    DateFilter? dateFilter,
  });

  Future<T> fetchById({required String id, required I itemIdentifier});


  Future<double?> fetchMetaData({required String id, required I itemIdentifier});

  Future<void> delete({required T item});

  Future<T> save({required T item});

  Future<int> countDocuments({required I itemIdentifier, QueryFilter? countQueryFilter});

  Future<List<T>> saveAll({required List<T> items, required I itemIdentifier});

  Future<Map<I, List<T>>> saveAllNested({
    required List<I> itemIdentifiers,
    required List<T> items,
    void Function(double progress)? onProgress,
  });
}
