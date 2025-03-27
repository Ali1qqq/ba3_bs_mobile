import '../../../../../core/models/date_filter.dart';
import '../../../../../core/models/query_filter.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/services/firebase/interfaces/queryable_savable_datasource.dart';
import '../../models/materials/material_model.dart';

class MaterialsSerialsDataSource extends QueryableSavableDatasource<SerialNumberModel> {
  MaterialsSerialsDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.materialsSerialNumbers; // Collection name in Firestore

  @override
  Future<List<SerialNumberModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final serialNumbers = data.map((item) => SerialNumberModel.fromJson(item)).toList();

    return serialNumbers;
  }

  @override
  Future<SerialNumberModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return SerialNumberModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<SerialNumberModel> save(SerialNumberModel item) async {
    final data = await databaseService.add(path: path, documentId: item.serialNumber, data: item.toJson());

    return SerialNumberModel.fromJson(data);
  }

  @override
  Future<List<SerialNumberModel>> saveAll(List<SerialNumberModel> items) async {
    final itemsToUpdate = items.map((item) {
      final docId = item.serialNumber; // Assuming `serialNumber` is the document ID

      // Convert all properties dynamically
      final itemData = item.toJson(); // Ensure toJson() includes all relevant fields

      return {
        'docId': docId,
        ...itemData, // Spread all dynamic fields
        'transactions': item.transactions.map((transaction) => transaction.toJson()).toList(),
      };
    }).toList();

    // Call batchUpdateWithArrayUnionOnList to merge transactions instead of overriding them
    final updatedItems = await databaseService.batchUpdateWithArrayUnionOnList(
      path: path,
      items: itemsToUpdate,
      docIdField: 'docId', // The field that identifies the document
      nestedFieldPath: 'transactions', // The nested field to apply arrayUnion on
    );

    // Convert the updated items back into SerialNumberModel objects
    return updatedItems.map(SerialNumberModel.fromJson).toList();
  }

  @override
  Future<List<SerialNumberModel>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter}) async {
    final data = await databaseService.fetchWhere(path: path, queryFilters: queryFilters, dateFilter: dateFilter);

    final serialNumbers = data.map((item) => SerialNumberModel.fromJson(item)).toList();

    return serialNumbers;
  }
}
