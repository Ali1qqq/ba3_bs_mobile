import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';

import '../../../../core/services/firebase/implementations/services/firebase_sequential_number_database.dart';
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
  Future<ChequesModel> save(ChequesModel item) async {
    final updatedCheque = item.chequesGuid == null ? await _assignChequeNumber(item) : item;

    final savedData = await _saveChequeData(updatedCheque.chequesGuid, updatedCheque.toJson());

    return item.chequesGuid == null ? ChequesModel.fromJson(savedData) : updatedCheque;
  }

  Future<ChequesModel> _assignChequeNumber(ChequesModel cheque) async {
    final newChequesNumber = await getNextNumber(path, ChequesType.byTypeGuide(cheque.chequesTypeGuid!).value);
    return cheque.copyWith(chequesNumber: newChequesNumber);
  }

  Future<Map<String, dynamic>> _saveChequeData(String? chequeId, Map<String, dynamic> data) async =>
      databaseService.add(path: path, documentId: chequeId, data: data);
}
