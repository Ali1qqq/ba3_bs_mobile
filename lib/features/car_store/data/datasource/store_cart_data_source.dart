import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/listen_datasource.dart';
import 'package:ba3_bs_mobile/features/car_store/data/model/store_cart.dart';

class StoreCartDataSource extends ListenableDatasource<StoreCartModel> {
  StoreCartDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.storeCart; // Collection name in Firestore

  @override
  Future<List<StoreCartModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final List<StoreCartModel> bonds = data.map((item) => StoreCartModel.fromJson(item)).toList();

    // Sort the list by `bondNumber` in ascending order
    bonds.sort((a, b) => a.id!.compareTo(b.id!));

    return bonds;
  }

  @override
  Future<StoreCartModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return StoreCartModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<StoreCartModel> save(StoreCartModel item) async {
    final savedData = await _saveStoreCartData(item.id, item.toJson());

    return StoreCartModel.fromJson(savedData);
  }

  Future<Map<String, dynamic>> _saveStoreCartData(String? bondId, Map<String, dynamic> data) async =>
      databaseService.add(path: path, documentId: bondId, data: data);

  @override
  Future<List<StoreCartModel>> saveAll(List<StoreCartModel> items) {
    // TODO: implement saveAll
    throw UnimplementedError();
  }

  @override
  Stream<StoreCartModel> subscribeToDoc({required String documentId}) {
    // TODO: implement subscribeToDoc
    throw UnimplementedError();
  }
}