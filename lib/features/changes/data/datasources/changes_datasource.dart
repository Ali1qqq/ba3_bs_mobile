import 'package:ba3_bs_mobile/features/changes/data/model/changes_model.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/services/firebase/interfaces/listen_datasource.dart';

/// Implementation of ListenDatasource
class ChangesListenDatasource extends ListenableDatasource<ChangesModel> {
  ChangesListenDatasource({required super.databaseService});

  @override
  Stream<ChangesModel> subscribeToDoc({required String documentId}) {
    return databaseService.subscribeToDoc(path: path, documentId: documentId).map((data) => ChangesModel.fromJson(data));
  }

  @override
  String get path => ApiConstants.changesPath; // Collection name in Firestore

  @override
  Future<List<ChangesModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);
    final changes = data.map((item) => ChangesModel.fromJson(item)).toList();

    return changes;
  }

  @override
  Future<ChangesModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return ChangesModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<ChangesModel> save(ChangesModel item) async {
    final data = await databaseService.add(path: path, documentId: item.changeId, data: item.toJson());

    return ChangesModel.fromJson(data);
  }

  @override
  Future<List<ChangesModel>> saveAll(List<ChangesModel> items) async {
    final savedData = await databaseService.addAll(
      path: path,
      data: items.map((item) => {...item.toJson(), 'docId': item.changeId}).toList(),
    );

    return savedData.map(ChangesModel.fromJson).toList();
  }
}
