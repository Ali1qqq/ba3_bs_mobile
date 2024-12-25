import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';

import '../../../../core/services/firebase/implementations/firebase_sequential_number_database.dart';
import '../../../../core/services/firebase/interfaces/datasource_base.dart';
import '../models/bond_model.dart';

class BondsDataSource extends DatasourceBase<BondModel> with FirebaseSequentialNumberDatabase {
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
  Future<BondModel> save(BondModel item, [bool? save]) async {
    if (item.payGuid == null) {
      final newBillModel = await _createNewBond(item);

      return newBillModel;
    } else {
      await databaseService.update(path: path, documentId: item.payGuid, data: item.toJson());
      return item;
    }
  }

  Future<BondModel> _createNewBond(BondModel bond) async {
    final newBondNumber = await getNextNumber(path, BondType.byTypeGuide(bond.payTypeGuid!).value);

    final newBondJson = bond.copyWith(payNumber: newBondNumber).toJson();

    final data = await databaseService.add(path: path, data: newBondJson);

    return BondModel.fromJson(data);
  }
}
