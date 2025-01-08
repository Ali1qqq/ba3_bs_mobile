// EntryBondsDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/bulk_savable_datasource.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';

class AccountsDataSource extends BulkSavableDatasource<AccountModel> {
  AccountsDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.accountsPath; // Collection name in Firestore

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
    final data = await databaseService.add(path: path, documentId: item.id, data: item.toJson());

    return AccountModel.fromJson(data);
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
