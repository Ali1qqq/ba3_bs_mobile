import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/services/local_database/interfaces/local_datasource_base.dart';
import 'package:ba3_bs_mobile/features/dashboard/data/model/dash_account_model.dart';

class DashboardAccountDataSource extends LocalDatasourceBase<DashAccountModel> {
  DashboardAccountDataSource(super.database);

  @override
  Future<void> saveData(DashAccountModel item) {
    return database.insert(item.id!, item);
  }

  @override
  Future<void> saveAllData(List<DashAccountModel> items) {
    final Map<String, DashAccountModel> dataMap = items.toMap(
      (item) => item.id!,
    );
    return database.insertAll(dataMap);
  }

  @override
  Future<List<DashAccountModel>> getAllData() => database.fetchAll();

  @override
  DashAccountModel? getDataById(String id) => database.fetchById(id);

  @override
  Future<void> removeData(DashAccountModel item) {
    return database.delete(item.id!);
  }

  @override
  Future<void> removeAllData(List<DashAccountModel> items) {
    final List<String> ids = items.select((item) => item.id!);
    return database.deleteAll(ids);
  }

  @override
  Future<void> clearAllData() => database.clear();

  @override
  Future<void> updateData(DashAccountModel item) {
    return database.update(item.id!, item);
  }

  @override
  Future<void> updateAllData(List<DashAccountModel> items) {
    final dataMap = items.toMap(
      (material) => material.id!,
    );

    return database.updateAll(dataMap);
  }
}