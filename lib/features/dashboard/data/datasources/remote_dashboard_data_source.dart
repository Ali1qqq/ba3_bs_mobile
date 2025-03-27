// EntryBondsDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/bulk_savable_datasource.dart';
import 'package:ba3_bs_mobile/features/dashboard/data/model/dash_account_model.dart';

class RemoteDashboardDataSource extends BulkSavableDatasource<DashAccountModel> {
  RemoteDashboardDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.dashBoardAccounts; // Collection name in Firestore

  @override
  Future<List<DashAccountModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final entryBonds = data.map((item) => DashAccountModel.fromJson(item)).toList();

    return entryBonds;
  }

  @override
  Future<DashAccountModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return DashAccountModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<DashAccountModel> save(DashAccountModel item) async {
    final data = await databaseService.add(path: path, documentId: item.id, data: item.toJson());

    return DashAccountModel.fromJson(data);
  }

  @override
  Future<List<DashAccountModel>> saveAll(List<DashAccountModel> items) async {
    final savedData = await databaseService.addAll(
      path: path,
      data: items.map((item) => item.toJson()).toList(),
    );

    return savedData.map(DashAccountModel.fromJson).toList();
  }
}