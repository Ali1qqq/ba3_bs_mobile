import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';

import '../../../../core/services/firebase/implementations/services/firebase_sequential_number_database.dart';
import '../../../../core/services/firebase/interfaces/remote_datasource_base.dart';
import '../models/bond_model.dart';

class BondsDataSource extends RemoteDatasourceBase<BondModel> with FirebaseSequentialNumberDatabase {
  BondsDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.bondsPath; // Collection name in Firestore

  @override
  Future<List<BondModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final List<BondModel> bonds = data.map((item) => BondModel.fromJson(item)).toList();

    // Sort the list by `bondNumber` in ascending order
    bonds.sort((a, b) => a.payNumber!.compareTo(b.payNumber!));

    return bonds;
  }

  @override
  Future<BondModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return BondModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<BondModel> save(BondModel item) async {
    final updatedBond = item.payGuid == null ? await _assignBondNumber(item) : item;

    final savedData = await _saveBondData(updatedBond.payGuid, updatedBond.toJson());

    return item.payGuid == null ? BondModel.fromJson(savedData) : updatedBond;
  }

  Future<BondModel> _assignBondNumber(BondModel bond) async {
    final newBondNumber = await getNextNumber(path, BondType.byTypeGuide(bond.payTypeGuid!).value);
    return bond.copyWith(payNumber: newBondNumber);
  }

  Future<Map<String, dynamic>> _saveBondData(String? bondId, Map<String, dynamic> data) async =>
      databaseService.add(path: path, documentId: bondId, data: data);
}
