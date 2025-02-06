import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/services/local_database/interfaces/local_datasource_base.dart';

import '../../models/materials/material_model.dart';

class MaterialsLocalDatasource extends LocalDatasourceBase<MaterialModel> {
  MaterialsLocalDatasource(super.database);

  @override
  Future<void> saveData(MaterialModel item) {
    return database.insert(item.id!, item);
  }

  @override
  Future<void> saveAllData(List<MaterialModel> items) {
    final Map<String, MaterialModel> dataMap = items.toMap(
      (material) => material.id!,
    );
    return database.insertAll(dataMap);
  }

  @override
  Future<List<MaterialModel>> getAllData() => database.fetchAll();

  @override
  Future<MaterialModel?> getDataById(String id) => database.fetchById(id);

  @override
  Future<void> removeData(MaterialModel item) {
    return database.delete(item.id!);
  }

  @override
  Future<void> removeAllData(List<MaterialModel> items) {
    final List<String> ids = items.select((item) => item.id!);
    return database.deleteAll(ids);
  }

  @override
  Future<void> clearAllData() => database.clear();

  @override
  Future<void> updateData(MaterialModel item) {
    return database.update(item.id!, item);
  }

  @override
  Future<void> updateAllData(List<MaterialModel> items) {
    final dataMap = items.toMap(
      (material) => material.id!,
    );

    return database.updateAll(dataMap);
  }
}
