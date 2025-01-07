// EntryBondsDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/datasource_base.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/entry_bond_model.dart';

class EntryBondsDataSource extends DatasourceBase<EntryBondModel> {
  EntryBondsDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.entryBonds; // Collection name in Firestore

  @override
  Future<List<EntryBondModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final entryBonds = data.map((item) => EntryBondModel.fromJson(item)).toList();

    return entryBonds;
  }

  @override
  Future<EntryBondModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return EntryBondModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<EntryBondModel> save(EntryBondModel item) async {
    final data = await databaseService.add(path: path, documentId: item.origin?.originId, data: item.toJson());

    return EntryBondModel.fromJson(data);
  }
}
