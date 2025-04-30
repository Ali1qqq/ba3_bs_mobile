// EntryBondsDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/bulk_savable_datasource.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';

import '../../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';

class AccountsDatasource extends BulkSavableDatasource<AccountModel> with FirestoreSequentialNumbers {
  AccountsDatasource({required super.databaseService});

  @override
  String get path => ApiConstants.accounts; // Collection name in Firestore

  @override
  Future<List<AccountModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final accounts = data.map((item) => AccountModel.fromJson(item)).toList();

    return accounts;
  }

  @override
  Future<AccountModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return AccountModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<AccountModel> save(AccountModel item) async {
    final updatedItem = item.id == null ? await _assignAccountNumber(item) : item;

    final savedData = await databaseService.add(
      path: path,
      documentId: updatedItem.id,
      data: updatedItem.toJson(),
    );

    return item.id == null ? AccountModel.fromJson(savedData) : updatedItem;
  }

  Future<AccountModel> _assignAccountNumber(AccountModel item) async {
    final newBillNumber = await fetchAndIncrementEntityNumber(path, "account");
    return item.copyWith(accNumber: newBillNumber.nextNumber);
  }

  @override
  Future<List<AccountModel>> saveAll(List<AccountModel> items) async {
    final savedData = await databaseService.addAll(
      path: path,
      data: items.map((item) => {...item.toJson(), 'docId': item.id}).toList(),
    );

    return savedData.map(AccountModel.fromJson).toList();
  }
}