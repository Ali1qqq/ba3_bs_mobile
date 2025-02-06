import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/compound_datasource_base.dart';

import '../../../../core/models/query_filter.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../models/bill_model.dart';

class BillCompoundDatasource extends CompoundDatasourceBase<BillModel, BillTypeModel> {
  BillCompoundDatasource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bills", "bonds")
  @override
  String get rootCollectionPath => ApiConstants.bills; // Collection name in Firestore

  @override
  Future<List<BillModel>> fetchAll({required BillTypeModel itemIdentifier}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subcollectionPath = getSubCollectionPath(itemIdentifier);

    final data = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
    );

    final bills = data.map((item) => BillModel.fromJson(item)).toList();

    bills.sort((a, b) => a.billDetails.billNumber!.compareTo(b.billDetails.billNumber!));

    return bills;
  }

  @override
  Future<List<BillModel>> fetchWhere<V>(
      {required BillTypeModel itemIdentifier, required String field, required V value, DateFilter? dateFilter}) async {
    final data = await compoundDatabaseService.fetchWhere(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: getRootDocumentId(itemIdentifier),
      subCollectionPath: getSubCollectionPath(itemIdentifier),
      field: field,
      value: value,
      dateFilter: dateFilter,
    );

    final bills = data.map((item) => BillModel.fromJson(item)).toList();

    return bills;
  }

  @override
  Future<BillModel> fetchById({required String id, required BillTypeModel itemIdentifier}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subcollectionPath = getSubCollectionPath(itemIdentifier);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: id,
    );

    return BillModel.fromJson(data);
  }

  @override
  Future<void> delete({required BillModel item}) async {
    final rootDocumentId = getRootDocumentId(item.billTypeModel);
    final subcollectionPath = getSubCollectionPath(item.billTypeModel);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: item.billId!,
    );
  }

  @override
  Future<BillModel> save({required BillModel item}) async {
    final rootDocumentId = getRootDocumentId(item.billTypeModel);
    final subCollectionPath = getSubCollectionPath(item.billTypeModel);

    final updatedBill = item.billId == null ? await _assignBillNumber(item) : item;

    final savedData = await _saveBillData(
      rootDocumentId,
      subCollectionPath,
      updatedBill.billId,
      updatedBill.toJson(),
    );

    return item.billId == null ? BillModel.fromJson(savedData) : updatedBill;
  }

  Future<BillModel> _assignBillNumber(BillModel bill) async {
    final billNumber = await getNextNumber(rootCollectionPath, bill.billTypeModel.billTypeLabel!);
    return bill.copyWith(billDetails: bill.billDetails.copyWith(billNumber: billNumber));
  }

  Future<Map<String, dynamic>> _saveBillData(
      String rootDocumentId, String subCollectionPath, String? billId, Map<String, dynamic> data) async {
    return compoundDatabaseService.add(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: billId,
      data: data,
    );
  }

  @override
  Future<int> countDocuments({required BillTypeModel itemIdentifier, QueryFilter? countQueryFilter}) async {
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
  Future<Map<BillTypeModel, List<BillModel>>> fetchAllNested({required List<BillTypeModel> itemIdentifiers}) async {
    final billsByType = <BillTypeModel, List<BillModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final billTypeModel in itemIdentifiers) {
      fetchTasks.add(
        fetchAll(itemIdentifier: billTypeModel).then((result) {
          billsByType[billTypeModel] = result;
        }),
      );
    }
    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return billsByType;
  }

  @override
  Future<Map<BillTypeModel, List<BillModel>>> saveAllNested({
    required List<BillTypeModel> itemIdentifiers,
    required List<BillModel> items,
    void Function(double progress)? onProgress,
  }) async {
    final billsByType = <BillTypeModel, List<BillModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final billTypeModel in itemIdentifiers) {
      fetchTasks.add(
        saveAll(
                itemIdentifier: billTypeModel,
                items: items
                    .where(
                      (element) => element.billTypeModel.billTypeId == billTypeModel.billTypeId,
                    )
                    .toList())
            .then((result) {
          billsByType[billTypeModel] = result;
        }),
      );
    }

    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return billsByType;
  }

  @override
  Future<List<BillModel>> saveAll({required List<BillModel> items, required BillTypeModel itemIdentifier}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subCollectionPath = getSubCollectionPath(itemIdentifier);

    final savedData = await compoundDatabaseService.saveAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      items: items.map((item) {
        return {
          ...item.toJson(),
          'docId': item.billId,
        };
      }).toList(),
    );

    return savedData.map(BillModel.fromJson).toList();
  }

  @override
  Future<double?> fetchMetaData({required String id, required BillTypeModel itemIdentifier}) {
    // TODO: implement fetchMetaData
    throw UnimplementedError();
  }
}
