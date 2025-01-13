import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/features/changes/data/model/changes_model.dart';

import '../../../../core/services/firebase/interfaces/listen_datasource.dart';

/// Implementation of ListenDatasource
class ChangesListenDatasource extends ListenableDatasource<ChangesModel> {
  ChangesListenDatasource({required super.databaseService});

  /// Subscribe to changes for a specific document ID
  @override
  Stream<ChangesModel> subscribeToDoc({required String documentId}) {
    return databaseService.subscribeToDoc(path: path, documentId: documentId).map((data) => ChangesModel.fromJson(data));
  }

  @override
  String get path => ApiConstants.changes; // Collection name in Firestore

  /// Fetch all changes
  @override
  Future<List<ChangesModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);
    return data.map((item) => ChangesModel.fromJson(item)).toList();
  }

  /// Fetch a change by its ID

  @override
  Future<ChangesModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return ChangesModel.fromJson(item);
  }

  /// Save or update a change
  @override
  Future<ChangesModel> save(ChangesModel item) async {
    final data = await databaseService.add(
      path: path,
      documentId: item.targetUserId,
      data: item.toJson(),
    );
    return ChangesModel.fromJson(data);
  }

  @override
  Future<List<ChangesModel>> saveAll(List<ChangesModel> items) async {
    // Convert ChangesModel items to the format required by batchUpdateWithArrayUnion
    final itemsToUpdate = items.map((item) {
      final docId = item.targetUserId;

      // Prepare the data in the required format for arrayUnion
      final nestedFieldData = <String, dynamic>{};

      item.changeItems.forEach((collection, changes) {
        nestedFieldData[collection.name] = changes.map((changeItem) => changeItem.toJson()).toList();
      });

      return {
        'docId': docId,
        'changeItems': nestedFieldData,
      };
    }).toList();

    // Call batchUpdateWithArrayUnion to handle the batch update with arrayUnion logic
    final updatedItems = await databaseService.batchUpdateWithArrayUnion(
      path: path,
      items: itemsToUpdate,
      docIdField: 'docId', // The field in the map that contains the docId
      nestedFieldPath: 'changeItems', // The nested field to apply arrayUnion on
    );

    // Process the updated items into ChangesModel
    return updatedItems.map((item) => ChangesModel.fromJson(item)).toList();
  }

  /// Delete a change by ID
  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id, mapFieldName: 'changeItems');
  }
}
