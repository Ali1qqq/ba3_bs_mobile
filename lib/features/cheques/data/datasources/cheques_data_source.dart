import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';

import '../../../../core/services/firebase/implementations/firebase_sequential_number_database.dart';
import '../../../../core/services/firebase/interfaces/datasource_base.dart';

import '../models/cheques_model.dart';

class ChequesDataSource extends DatasourceBase<ChequesModel> with FirebaseSequentialNumberDatabase {
  ChequesDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.chequesPath; // Collection name in Firestore

  @override
  Future<List<ChequesModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final List<ChequesModel> chequesList = data.map((item) => ChequesModel.fromJson(item)).toList();

    // Sort the list by `chequesNumber` in ascending order
    chequesList.sort((a, b) => a.chequesNumber!.compareTo(b.chequesNumber!));

    return chequesList;
  }

  @override
  Future<ChequesModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return ChequesModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<ChequesModel> save(ChequesModel item, [bool? save]) async {
    if (item.chequesGuid == null) {
      final newBillModel = await _createNewCheques(item);

      return newBillModel;
    } else {
      await databaseService.update(path: path, documentId: item.chequesGuid, data: item.toJson());
      return item;
    }
  }

  Future<ChequesModel> _createNewCheques(ChequesModel cheques) async {
    final newChequesNumber = await getNextNumber(path, ChequesType.byTypeGuide(cheques.chequesTypeGuid!).value);
    final newChequesJson = cheques.copyWith(chequesNumber: newChequesNumber).toJson();
    final data = await databaseService.add(path: path, data: newChequesJson);
    return ChequesModel.fromJson(data);
  }

// Future<BondModel> saveBond(BondModel item) async {
//   if (item.payGuid == null) {
//     final newBillModel = await _createNewBond(item);
//
//     return newBillModel;
//   } else {
//     await databaseService.update(path: ApiConstants.bondsChequesPath, documentId: item.payGuid, data: item.toJson());
//     return item;
//   }
// }
//
// Future<BondModel> _createNewBond(BondModel bond) async {
//   final newBondNumber = await getNextNumber(path, bond.payTypeGuid!);
//
//   final newBondJson = bond.copyWith(payNumber: newBondNumber).toJson();
//
//   final data = await databaseService.add(path: ApiConstants.bondsChequesPath, data: newBondJson);
//
//   return BondModel.fromJson(data);
// }
}
