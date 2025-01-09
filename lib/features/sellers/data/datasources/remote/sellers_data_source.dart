// SellersDataSource Implementation
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/bulk_savable_datasource.dart';

import '../../models/seller_model.dart';

class SellersDatasource extends BulkSavableDatasource<SellerModel> {
  SellersDatasource({required super.databaseService});

  @override
  String get path => ApiConstants.sellers; // Collection name in Firestore

  @override
  Future<List<SellerModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final sellers = data.map((item) => SellerModel.fromJson(item)).toList();

    return sellers;
  }

  @override
  Future<SellerModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return SellerModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<SellerModel> save(SellerModel item) async {
    final data = await databaseService.add(path: path, documentId: item.costGuid, data: item.toJson());

    return SellerModel.fromJson(data);
  }

  @override
  Future<List<SellerModel>> saveAll(List<SellerModel> items) async {
    final savedData = await databaseService.addAll(
      path: path,
      data: items.map((item) => {...item.toJson(), 'docId': item.costGuid}).toList(),
    );

    return savedData.map(SellerModel.fromJson).toList();
  }
}
