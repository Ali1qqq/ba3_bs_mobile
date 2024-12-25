// BillsDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/filterable_data_source.dart';

import '../../../../core/services/firebase/implementations/firebase_sequential_number_database.dart';
import '../models/bill_model.dart';

class BillsDataSource extends FilterableDatasource<BillModel> with FirebaseSequentialNumberDatabase {
  BillsDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.billsPath; // Collection name in Firestore

  @override
  Future<List<BillModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final bills = data.map((item) => BillModel.fromJson(item)).toList();

    // Sort the list by `billNumber` in ascending order
    bills.sort((a, b) => a.billDetails.billNumber!.compareTo(b.billDetails.billNumber!));

    return bills;
  }

  @override
  Future<BillModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return BillModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<BillModel> save(BillModel item, [bool? save]) async {
    if (item.billId == null) {
      final newBillModel = await _createNewBill(item);

      return newBillModel;
    } else {
      await databaseService.update(path: path, documentId: item.billId, data: item.toJson());
      return item;
    }
  }

  Future<BillModel> _createNewBill(BillModel bill) async {
    final newBillNumber = await getNextNumber(path, bill.billTypeModel.billTypeLabel!);

    final newBillJson = bill.copyWith(billDetails: bill.billDetails.copyWith(billNumber: newBillNumber)).toJson();

    final data = await databaseService.add(path: path, data: newBillJson);

    return BillModel.fromJson(data);
  }

  @override
  Future<List<BillModel>> fetchWhere<V>({required String field, required V value}) async {
    final data = await databaseService.fetchWhere(path: path, field: field, value: value);

    final users = data.map((item) => BillModel.fromJson(item)).toList();

    return users;
  }
}
