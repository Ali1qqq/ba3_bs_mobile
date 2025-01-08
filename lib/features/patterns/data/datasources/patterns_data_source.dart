import '../../../../core/network/api_constants.dart';
import '../../../../core/services/firebase/interfaces/remote_datasource_base.dart';
import '../models/bill_type_model.dart';

class PatternsDataSource extends RemoteDatasourceBase<BillTypeModel> {
  PatternsDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.patternsPath; // Collection name in Firestore

  @override
  Future<List<BillTypeModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);
    final billTypes = data.map((item) => BillTypeModel.fromJson(item)).toList();

    // Sort the bill types by account count
    billTypes.sort((a, b) {
      int countA = a.accounts?.length ?? 0;
      int countB = b.accounts?.length ?? 0;
      return countB.compareTo(countA); // Sort in descending order
    });

    return billTypes;
  }

  @override
  Future<BillTypeModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return BillTypeModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<BillTypeModel> save(BillTypeModel item) async {
    final data = await databaseService.add(path: path, documentId: item.id, data: item.toJson());

    return BillTypeModel.fromJson(data);
  }
}
