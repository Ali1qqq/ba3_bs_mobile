// // BillsDataSource Implementation
// import 'package:ba3_bs/core/network/api_constants.dart';
// import 'package:ba3_bs/core/services/firebase/interfaces/filterable_datasource.dart';
//
// import '../../../../core/models/date_filter.dart';
// import '../../../../core/models/query_filter.dart';
// import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
// import '../models/bill_model.dart';
//
// class BillsDataSource extends FilterableDatasource<BillModel> with FirestoreSequentialNumbers {
//   BillsDataSource({required super.databaseService});
//
//   @override
//   String get path => ApiConstants.bills; // Collection name in Firestore
//
//   @override
//   Future<List<BillModel>> fetchAll() async {
//     final data = await databaseService.fetchAll(path: path);
//
//     final bills = data.map((item) => BillModel.fromJson(item)).toList();
//
//     // Sort the list by `billNumber` in ascending order
//     bills.sort((a, b) => a.billDetails.billNumber!.compareTo(b.billDetails.billNumber!));
//
//     return bills;
//   }
//
//   @override
//   Future<BillModel> fetchById(String id) async {
//     final item = await databaseService.fetchById(path: path, documentId: id);
//     return BillModel.fromJson(item);
//   }
//
//   @override
//   Future<void> delete(String id) async {
//     await databaseService.delete(path: path, documentId: id);
//   }
//
//   @override
//   Future<BillModel> save(BillModel item) async {
//     final updatedBill = item.billId == null ? await _assignBillNumber(item) : item;
//
//     final savedData = await _saveBillData(updatedBill.billId, updatedBill.toJson());
//
//     return item.billId == null ? BillModel.fromJson(savedData) : updatedBill;
//   }
//
//   Future<BillModel> _assignBillNumber(BillModel bill) async {
//     final newBillNumber = await getNextNumber(path, bill.billTypeModel.billTypeLabel!);
//     return bill.copyWith(billDetails: bill.billDetails.copyWith(billNumber: newBillNumber.nextNumber));
//   }
//
//   Future<Map<String, dynamic>> _saveBillData(String? billId, Map<String, dynamic> data) async =>
//       databaseService.add(path: path, documentId: billId, data: data);
//
//   @override
//   Future<List<BillModel>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter}) async {
//     final data = await databaseService.fetchWhere(path: path, queryFilters: queryFilters);
//
//     final users = data.map((item) => BillModel.fromJson(item)).toList();
//
//     return users;
//   }
// }
