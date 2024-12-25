// Firebase-Specific Implementation
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/i_database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// FirebaseFirestoreService Implementation
class FireStoreService extends IDatabaseService<Map<String, dynamic>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchAll({required String path}) async {
    final snapshot = await _firestore.collection(path).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWhere<V>(
      {required String path, required String field, required V value}) async {
    final snapshot = await _firestore.collection(path).where(field, isEqualTo: value).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<Map<String, dynamic>> fetchById({required String path, String? documentId}) async {
    final doc = await _firestore.collection(path).doc(documentId).get();
    if (doc.exists) {
      return doc.data()!;
    } else {
      throw Exception('Document not found');
    }
  }

  @override
  Future<void> delete({required String path, String? documentId}) async {
    await _firestore.collection(path).doc(documentId).delete();
  }

  @override
  Future<Map<String, dynamic>> add(
      {required String path, String? documentId, required Map<String, dynamic> data}) async {
    if (documentId == null) {
      final docId = _firestore.collection(path).doc().id;

      data['docId'] = docId;

      await _firestore.collection(path).doc(docId).set(data);
    } else {
      await _firestore.collection(path).doc(documentId).set(data);
    }

    return data;
  }

  @override
  Future<void> update({required String path, String? documentId, required Map<String, dynamic> data}) async {
    await _firestore.collection(path).doc(documentId).update(data);
  }

  @override
  Future<List<Map<String, dynamic>>> addAll({
    required String path,
    required List<Map<String, dynamic>> data,
  }) async {
    final batch = _firestore.batch();
    final addedItems = <Map<String, dynamic>>[];

    for (final item in data) {
      // Assign docId only if it is null
      final docId = item['docId'] ?? _firestore.collection(path).doc().id;
      if (item['docId'] == null) {
        item['docId'] = docId;
      }
      final docRef = _firestore.collection(path).doc(docId);
      batch.set(docRef, item);

      // Collect the item with its final docId
      addedItems.add(item);
    }

    await batch.commit();
    return addedItems;
  }
}
