// EntryBondsDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/bulk_savable_datasource.dart';

import '../../models/customer_model.dart';

class CustomersDatasource extends BulkSavableDatasource<CustomerModel> {
  CustomersDatasource({required super.databaseService});

  @override
  String get path => ApiConstants.customers; // Collection name in Firestore

  @override
  Future<List<CustomerModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final entryBonds = data.map((item) => CustomerModel.fromJson(item)).toList();

    return entryBonds;
  }

  @override
  Future<CustomerModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return CustomerModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<CustomerModel> save(CustomerModel item) async {
    final data = await databaseService.add(path: path, documentId: item.id, data: item.toJson());

    return CustomerModel.fromJson(data);
  }

  @override
  Future<List<CustomerModel>> saveAll(List<CustomerModel> items) async {
    final savedData = await databaseService.addAll(
      path: path,
      data: items.map((item) => item.toJson()).toList(),
    );

    return savedData.map(CustomerModel.fromJson).toList();
  }
}
