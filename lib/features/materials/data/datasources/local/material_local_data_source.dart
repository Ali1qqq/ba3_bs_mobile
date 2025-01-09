// MaterialsDataSource Implementation

import '../../../../../core/services/local_database/interfaces/local_datasource_base.dart';
import '../../models/material_model.dart';

class MaterialsLocalDataSource extends LocalDatasourceBase<MaterialModel> {
  MaterialsLocalDataSource(super.database);

  @override
  Future<void> saveData(MaterialModel data) => database.insert(data);

  @override
  Future<void> saveAllData(List<MaterialModel> data) => database.insertAll(data);

  @override
  Future<List<MaterialModel>> getAllData() => database.fetchAll();

  @override
  Future<MaterialModel?> getDataById(String id) => database.fetchById(id);

  @override
  Future<void> removeData(String id) => database.delete(id);

  @override
  Future<void> clearAllData() => database.clear();
}
