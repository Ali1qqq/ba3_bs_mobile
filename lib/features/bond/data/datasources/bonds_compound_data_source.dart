import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';

import '../../../../core/models/date_filter.dart';
import '../../../../core/services/firebase/interfaces/compound_datasource_base.dart';
import '../models/bond_model.dart';

class BondCompoundDatasource extends CompoundDatasourceBase<BondModel, BondType> {
  BondCompoundDatasource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bonds", "bonds")
  @override
  String get rootCollectionPath => ApiConstants.bonds; // Collection name in Firestore

  @override
  Future<List<BondModel>> fetchAll({required BondType itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
    );

    final bonds = data.map((item) => BondModel.fromJson(item)).toList();

    bonds.sort((a, b) => a.payNumber!.compareTo(b.payNumber!));

    return bonds;
  }

  @override
  Future<List<BondModel>> fetchWhere<V>(
      {required BondType itemTypeModel, required String field, required V value, DateFilter? dateFilter}) async {
    final data = await compoundDatabaseService.fetchWhere(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: getRootDocumentId(itemTypeModel),
        subCollectionPath: getSubCollectionPath(itemTypeModel),
        field: field,
        value: value,
        dateFilter: dateFilter);

    final users = data.map((item) => BondModel.fromJson(item)).toList();

    return users;
  }

  @override
  Future<BondModel> fetchById({required String id, required BondType itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: id,
    );

    return BondModel.fromJson(data);
  }

  @override
  Future<void> delete({required BondModel item}) async {
    BondType bondType = BondType.byTypeGuide(item.payTypeGuid!);
    final rootDocumentId = getRootDocumentId(bondType);
    final subCollectionPath = getSubCollectionPath(bondType);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: item.payGuid!,
    );
  }

  @override
  Future<BondModel> save({required BondModel item}) async {
    final rootDocumentId = getRootDocumentId(BondType.byTypeGuide(item.payTypeGuid!));
    final subCollectionPath = getSubCollectionPath(BondType.byTypeGuide(item.payTypeGuid!));

    final updatedBond = item.payGuid == null ? await _assignBondNumber(item) : item;

    final savedData = await _saveBondData(
      rootDocumentId,
      subCollectionPath,
      updatedBond.payGuid,
      updatedBond.toJson(),
    );

    return item.payGuid == null ? BondModel.fromJson(savedData) : updatedBond;
  }

  Future<BondModel> _assignBondNumber(BondModel bond) async {
    final newBondNumber = await getNextNumber(rootCollectionPath, bond.payTypeGuid!);
    return bond.copyWith(payNumber: newBondNumber);
  }

  Future<Map<String, dynamic>> _saveBondData(
          String rootDocumentId, String subCollectionPath, String? bondId, Map<String, dynamic> data) async =>
      compoundDatabaseService.add(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: rootDocumentId,
        subCollectionPath: subCollectionPath,
        subDocumentId: bondId,
        data: data,
      );

  @override
  Future<int> countDocuments({required BondType itemTypeModel, QueryFilter<dynamic>? countQueryFilter}) async {
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
  Future<Map<BondType, List<BondModel>>> fetchAllNested({required List<BondType> itemTypes}) async {
    final bondsByType = <BondType, List<BondModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final bondTypeModel in itemTypes) {
      fetchTasks.add(
        fetchAll(itemTypeModel: bondTypeModel).then((result) {
          bondsByType[bondTypeModel] = result;
        }),
      );
    }
    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return bondsByType;
  }

  @override
  Future<Map<BondType, List<BondModel>>> saveAllNested({required List<BondType> itemTypes, required List<BondModel> items}) {
    // TODO: implement saveAllNested
    throw UnimplementedError();
  }

  @override
  Future<List<BondModel>> saveAll({required List<BondModel> items, required BondType itemTypeModel}) {
    // TODO: implement saveAll
    throw UnimplementedError();
  }
}
