import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/network/api_constants.dart';
import '../models/bill_items.dart';
import '../models/bill_model.dart';

abstract class FirstPeriodInventoryDataSource {
  final FirebaseFirestore firestore;

  final String _parentCollection = ApiConstants.largeBills;

  FirstPeriodInventoryDataSource(this.firestore);

  /// Uploads the Bill document (minus items) and then
  /// uploads items in multiple chunks to a subcollection.
  ///
  /// [onProgress] gets called with a value from 0..1 after each chunk.
  Future<void> uploadBillAndItemsInChunks({
    required BillModel bill,
    required void Function(double) onProgress,
    int chunkSize = 250,
  });

  /// Fetches all items for a given bill from the 'items' subcollection,
  /// merging chunk documents back into one list.
  Future<List<BillItem>> fetchBillItems({
    required String billTypeId,
    required String billTypeLabel,
    required String billId,
  });
}

class FirstPeriodInventoryDataSourceImpl extends FirstPeriodInventoryDataSource {
  FirstPeriodInventoryDataSourceImpl(super.firestore);

  @override
  Future<void> uploadBillAndItemsInChunks({
    required BillModel bill,
    required void Function(double) onProgress,
    int chunkSize = 250,
  }) async {
    final billsCollection =
        firestore.collection(_parentCollection).doc(bill.billTypeModel.billTypeId).collection(bill.billTypeModel.billTypeLabel!);
    final billDocRef = billsCollection.doc(bill.billId);

    final billWithoutItems = bill.copyWith(
      items: bill.items.copyWith(itemList: []),
    );
    await billDocRef.set(billWithoutItems.toJson(), SetOptions(merge: true));

    final items = bill.items.itemList;
    final chunks = items.chunkBy(chunkSize);
    final totalChunks = chunks.length;

    for (int i = 0; i < totalChunks; i++) {
      final chunk = chunks[i];
      final itemsSubcollection = billDocRef.collection('items');
      final chunkDocRef = itemsSubcollection.doc('chunk_$i');

      final chunkJson = chunk.map((item) => item.toJson()).toList();
      await chunkDocRef.set({
        'chunkIndex': i,
        'items': chunkJson,
      });

      onProgress((i + 1) / totalChunks);
    }
  }

  @override
  Future<List<BillItem>> fetchBillItems({
    required String billTypeId,
    required String billTypeLabel,
    required String billId,
  }) async {
    final itemsSnapshot = await firestore
        .collection(_parentCollection)
        .doc(billTypeId)
        .collection(billTypeLabel)
        .doc(billId)
        .collection('items')
        .orderBy('chunkIndex')
        .get();

    final allItems = <BillItem>[];
    for (final doc in itemsSnapshot.docs) {
      final data = doc.data();
      final itemsList = data['items'] as List<dynamic>? ?? [];
      final chunkItems = itemsList.map((json) => BillItem.fromJson(json)).toList();
      allItems.addAll(chunkItems);
    }
    return allItems;
  }
}