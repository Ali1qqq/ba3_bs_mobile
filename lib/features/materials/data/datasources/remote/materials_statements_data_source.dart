import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/compound_datasource_base.dart';

import '../../../../../core/models/query_filter.dart';
import '../../models/mat_statement/mat_statement_model.dart';

class MaterialsStatementsDatasource extends CompoundDatasourceBase<MatStatementModel, String> {
  MaterialsStatementsDatasource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bills", "bonds")
  @override
  String get rootCollectionPath => ApiConstants.materialsStatements; // Collection name in Firestore

  @override
  Future<List<MatStatementModel>> fetchAll({required String itemIdentifier}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subcollectionPath = getSubCollectionPath(itemIdentifier);

    final dataList = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
    );

    final matStatements = dataList.map((item) => MatStatementModel.fromJson(item)).toList();

    return matStatements;
  }

  @override
  Future<List<MatStatementModel>> fetchWhere<V>({
    required String itemIdentifier,
    required String field,
    required V value,
    DateFilter? dateFilter,
  }) async {
    final dataList = await compoundDatabaseService.fetchWhere(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: getRootDocumentId(itemIdentifier),
      subCollectionPath: getSubCollectionPath(itemIdentifier),
      field: field,
      value: value,
      dateFilter: dateFilter,
    );

    final matStatements = dataList.map((item) => MatStatementModel.fromJson(item)).toList();

    return matStatements;
  }

  @override
  Future<MatStatementModel> fetchById({required String id, required String itemIdentifier}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subcollectionPath = getSubCollectionPath(itemIdentifier);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: id,
    );

    return MatStatementModel.fromJson(data);
  }

  @override
  Future<void> delete({required MatStatementModel item}) async {
    final String id = item.matId!;

    final rootDocumentId = getRootDocumentId(id);
    final subcollectionPath = getSubCollectionPath(id);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: item.originId,
    );
  }

  @override
  Future<MatStatementModel> save({required MatStatementModel item}) async {
    final String id = item.matId!;

    final rootDocumentId = getRootDocumentId(id);
    final subCollectionPath = getSubCollectionPath(id);

    final savedData = await compoundDatabaseService.add(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: item.originId,
      data: item.toJson(),
    );

    return MatStatementModel.fromJson(savedData);
  }

  @override
  Future<int> countDocuments({required String itemIdentifier, QueryFilter? countQueryFilter}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subCollectionPath = getSubCollectionPath(itemIdentifier);

    final count = await compoundDatabaseService.countDocuments(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      countQueryFilter: countQueryFilter,
    );

    return count;
  }

  @override
  Future<Map<String, List<MatStatementModel>>> fetchAllNested({required List<String> itemIdentifiers}) async {
    final matStatementById = <String, List<MatStatementModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final matId in itemIdentifiers) {
      fetchTasks.add(
        fetchAll(itemIdentifier: matId).then((result) {
          matStatementById[matId] = result;
        }),
      );
    }
    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return matStatementById;
  }

  @override
  Future<Map<String, List<MatStatementModel>>> saveAllNested({
    required List<String> itemIdentifiers,
    required List<MatStatementModel> items,
    void Function(double progress)? onProgress,
  }) async {
    final matStatementById = <String, List<MatStatementModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final matId in itemIdentifiers) {
      fetchTasks.add(
        saveAll(
          itemIdentifier: matId,
          items: items.where((element) => element.matId == matId).toList(),
        ).then((result) {
          matStatementById[matId] = result;
        }),
      );
    }

    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return matStatementById;
  }

  @override
  Future<List<MatStatementModel>> saveAll({required List<MatStatementModel> items, required String itemIdentifier}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subCollectionPath = getSubCollectionPath(itemIdentifier);

    final savedData = await compoundDatabaseService.saveAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      items: items.map((item) => item.toJson()).toList(),
    );

    return savedData.map(MatStatementModel.fromJson).toList();
  }
}
