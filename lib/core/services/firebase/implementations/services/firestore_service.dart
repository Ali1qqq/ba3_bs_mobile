// Firebase-Specific Implementation
import 'dart:developer';

import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/i_remote_database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/date_filter.dart';

// FirebaseFirestoreService Implementation
class FireStoreService extends IRemoteDatabaseService<Map<String, dynamic>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchAll({required String path}) async {
    final snapshot = await _firestore.collection(path).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWhere({
    required String path,
    required List<QueryFilter> queryFilters,
    DateFilter? dateFilter,
  }) async {
    // Build the base query and apply filters
    final query = _applyDateFilterIfNeeded(
      _applyFilters(_firestore.collection(path), queryFilters),
      dateFilter,
    );

    // Execute the query and return the results
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

// Applies filters to the query
  Query<Map<String, dynamic>> _applyFilters(CollectionReference<Map<String, dynamic>> collection, List<QueryFilter> queryFilters) =>
      queryFilters.fold<Query<Map<String, dynamic>>>(
        collection,
        (query, filter) => query.where(filter.field, isEqualTo: filter.value),
      );

// Applies the date filter if provided
  Query<Map<String, dynamic>> _applyDateFilterIfNeeded(Query<Map<String, dynamic>> query, DateFilter? dateFilter) {
    if (dateFilter == null) return query;

    final start = dateFilter.range.start;
    final end = DateTime(dateFilter.range.end.year, dateFilter.range.end.month, dateFilter.range.end.day, 23, 59, 59, 999);

    return query.where(dateFilter.dateFieldName, isGreaterThanOrEqualTo: start).where(dateFilter.dateFieldName, isLessThanOrEqualTo: end);
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
  Future<Map<String, dynamic>> add({required Map<String, dynamic> data, required String path, String? documentId}) async {
    final newDoc = _firestore.collection(path).doc().id;

    // Use the provided document ID or generate a new one if not provided
    final docId = documentId ?? (data['docId'] ?? newDoc);

    // Ensure the docId is set in the data map if it is null
    if (data['docId'] == null) data['docId'] = docId;

    final docRef = _firestore.collection(path).doc(docId);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists && documentId != null) {
      await update(path: path, documentId: docId, data: data);
    } else {
      await docRef.set(data);
    }

    return data;
  }

  @override
  Future<void> update({required String path, String? documentId, required Map<String, dynamic> data}) async {
    log('update path $path, $documentId');
    await _firestore.collection(path).doc(documentId).update(data);
  }

  @override
  Future<List<Map<String, dynamic>>> addAll({required String path, required List<Map<String, dynamic>> data}) async {
    final batch = _firestore.batch();
    final addedItems = <Map<String, dynamic>>[];

    for (final item in data) {
      // Ensure the document ID is set
      final docId = item.putIfAbsent('docId', () => _firestore.collection(path).doc().id);

      // Add the item to the batch
      final docRef = _firestore.collection(path).doc(docId);
      batch.set(docRef, item);

      // Collect the processed item
      addedItems.add(item);
    }

    await batch.commit();
    return addedItems;
  }

  @override
  Stream<Map<String, dynamic>> subscribeToDoc({required String path, String? documentId}) {
    if (documentId == null || documentId.isEmpty) {
      throw ArgumentError("Document ID cannot be null or empty");
    }

    final documentStream = _firestore.collection(path).doc(documentId).snapshots();

    return documentStream.map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data()!;
      } else {
        throw Exception("Document does not exist at path: $documentId");
      }
    }).handleError((error) {
      // Handle Firestore or network errors here
      throw Exception("Error listening to document: $error");
    });
  }
}
