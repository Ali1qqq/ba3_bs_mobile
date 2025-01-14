import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';

import '../../../../core/models/date_filter.dart';
import '../../../../core/services/firebase/interfaces/compound_datasource_base.dart';
import '../models/cheques_model.dart';

class ChequesCompoundDatasource extends CompoundDatasourceBase<ChequesModel, ChequesType> {
  ChequesCompoundDatasource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "chequess", "chequess")
  @override
  String get rootCollectionPath => ApiConstants.cheques; // Collection name in Firestore

  @override
  Future<List<ChequesModel>> fetchAll({required ChequesType itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
    );

    final chequesList = data.map((item) => ChequesModel.fromJson(item)).toList();

    chequesList.sort((a, b) => a.chequesNumber!.compareTo(b.chequesNumber!));

    return chequesList;
  }

  @override
  Future<List<ChequesModel>> fetchWhere<V>(
      {required ChequesType itemTypeModel, required String field, required V value, DateFilter? dateFilter}) async {
    final data = await compoundDatabaseService.fetchWhere(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: getRootDocumentId(itemTypeModel),
        subCollectionPath: getSubCollectionPath(itemTypeModel),
        field: field,
        value: value,
        dateFilter: dateFilter);

    final users = data.map((item) => ChequesModel.fromJson(item)).toList();

    return users;
  }

  @override
  Future<ChequesModel> fetchById({required String id, required ChequesType itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: id,
    );

    return ChequesModel.fromJson(data);
  }

  @override
  Future<void> delete({required ChequesModel item}) async {
    ChequesType chequesType = ChequesType.byTypeGuide(item.chequesTypeGuid!);
    final rootDocumentId = getRootDocumentId(chequesType);
    final subCollectionPath = getSubCollectionPath(chequesType);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: item.chequesGuid!,
    );
  }

  @override
  Future<ChequesModel> save({required ChequesModel item}) async {
    final chequesType = ChequesType.byTypeGuide(item.chequesTypeGuid!);
    final rootDocumentId = getRootDocumentId(chequesType);
    final subCollectionPath = getSubCollectionPath(chequesType);

    final updatedCheques = item.chequesGuid == null ? await _assignChequesNumber(item) : item;

    final savedData = await _saveChequesData(
      rootDocumentId,
      subCollectionPath,
      updatedCheques.chequesGuid,
      updatedCheques.toJson(),
    );

    return item.chequesGuid == null ? ChequesModel.fromJson(savedData) : updatedCheques;
  }

  Future<ChequesModel> _assignChequesNumber(ChequesModel cheques) async {
    final newChequesNumber = await getNextNumber(rootCollectionPath, cheques.chequesTypeGuid!);
    return cheques.copyWith(chequesNumber: newChequesNumber);
  }

  Future<Map<String, dynamic>> _saveChequesData(
          String rootDocumentId, String subCollectionPath, String? chequesId, Map<String, dynamic> data) async =>
      compoundDatabaseService.add(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: rootDocumentId,
        subCollectionPath: subCollectionPath,
        subDocumentId: chequesId,
        data: data,
      );

  @override
  Future<int> countDocuments({required ChequesType itemTypeModel, QueryFilter<dynamic>? countQueryFilter}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final count = await compoundDatabaseService.countDocuments(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      countQueryFilter: countQueryFilter,
    );

    return count;
  }

  @override
  Future<Map<ChequesType, List<ChequesModel>>> fetchAllNested({required List<ChequesType> itemTypes}) async {
    final chequesMapByType = <ChequesType, List<ChequesModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final chequesTypeModel in itemTypes) {
      fetchTasks.add(
        fetchAll(itemTypeModel: chequesTypeModel).then((result) {
          chequesMapByType[chequesTypeModel] = result;
        }),
      );
    }
    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return chequesMapByType;
  }

  @override
  Future<List<ChequesModel>> saveAll({required List<ChequesModel> items, required ChequesType itemTypeModel}) {
    // TODO: implement saveAll
    throw UnimplementedError();
  }

  @override
  Future<Map<ChequesType, List<ChequesModel>>> saveAllNested({required List<ChequesType> itemTypes, required List<ChequesModel> items}) {
    // TODO: implement saveAllNested
    throw UnimplementedError();
  }
}
