import '../../../models/date_filter.dart';
import '../../../models/query_filter.dart';
import '../implementations/services/firebase_sequential_number_database.dart';
import '../implementations/services/firestore_path_helper.dart';
import 'i_compound_database_service.dart';

abstract class CompoundDatasourceBase<T, ItemTypeModel>
    with FirestorePathHelper<ItemTypeModel>, FirebaseSequentialNumberDatabase {
  final ICompoundDatabaseService<Map<String, dynamic>> compoundDatabaseService;

  CompoundDatasourceBase({required this.compoundDatabaseService});

  // Path getter to be overridden by subclasses
  String get rootCollectionPath;

  Future<List<T>> fetchAll({required ItemTypeModel itemTypeModel});

  Future<Map<ItemTypeModel, List<T>>> fetchAllNested({required List<ItemTypeModel> itemTypes});

  Future<List<T>> fetchWhere<V>({
    required ItemTypeModel itemTypeModel,
    required String field,
    required V value,
    DateFilter? dateFilter,
  });

  Future<T> fetchById({required String id, required ItemTypeModel itemTypeModel});

  Future<void> delete({required T item});

  Future<T> save({required T item});

  Future<int> countDocuments({required ItemTypeModel itemTypeModel, QueryFilter? countQueryFilter});

  Future<List<T>> saveAll({required List<T> items, required ItemTypeModel itemTypeModel});

  Future<Map<ItemTypeModel, List<T>>> saveAllNested({
    required List<ItemTypeModel> itemTypes,
    required List<T> items,
  });
}
