import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/date_filter.dart';
import '../../../../models/query_filter.dart';
import '../../../../network/api_constants.dart';
import '../../interfaces/i_compound_database_service.dart';

class CompoundFireStoreService extends ICompoundDatabaseService<Map<String, dynamic>> {
  final FirebaseFirestore _firestoreInstance;

  CompoundFireStoreService(FirebaseFirestore instance) : _firestoreInstance = instance;

  @override
  Future<List<Map<String, dynamic>>> fetchAll(
      {required String rootCollectionPath, required String rootDocumentId, required String subCollectionPath}) async {
    final querySnapshot = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).get();
    return (await querySnapshot).docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWhere<V>({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    required String field,
    required V value,
    DateFilter? dateFilter,
  }) async {
    // Build the base query
    Query<Map<String, dynamic>> query =
        _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).where(field, isEqualTo: value);

    // Apply date filter if provided
    if (dateFilter != null) {
      query = _applyDateFilter(query, dateFilter);
    }

    // Execute the query and return results
    final snapshot = await query.get();

    log("snapshot: ${snapshot.docs.length}");
    if (snapshot.docs.isEmpty) {
      throw Exception(
          "No results were found for querying the field '$field' with the value '$value' in the sub-collection '$subCollectionPath'.");
    }
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

// Helper method to apply the date filter to the query
  Query<Map<String, dynamic>> _applyDateFilter(Query<Map<String, dynamic>> query, DateFilter dateFilter) {
    // The start date/time for the range filter (inclusive).
    final start = dateFilter.range.start;

    // Adjust the end date to include the entire day up to the last millisecond (23:59:59.999).
    // This ensures that timestamps on the end date are not unintentionally excluded.
    final end = DateTime(dateFilter.range.end.year, dateFilter.range.end.month, dateFilter.range.end.day, 23, 59, 59, 999);

    // Apply the date range filters to the query.
    // - Greater than or equal to the start ensures we capture all entries from the start date onward.
    // - Less than or equal to the adjusted end ensures we include all entries up to the end of the specified date.
    return query.where(dateFilter.dateFieldName, isGreaterThanOrEqualTo: start).where(dateFilter.dateFieldName, isLessThanOrEqualTo: end);
  }

  @override
  Future<Map<String, dynamic>> fetchById({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
  }) async {
    final docSnapshot =
        await _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc(subDocumentId).get();
    if (docSnapshot.exists) {
      return docSnapshot.data()!;
    } else {
      throw Exception('Document not found');
    }
  }

  @override
  Future<Map<String, dynamic>> add({
    required Map<String, dynamic> data,
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
    double? metaValue,
  }) async {
    // Generate or use existing document ID
    final newDoc = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc().id;

    // Use the provided subDocumentId or generate a new one if not provided
    final docId = subDocumentId ?? (data['docId'] ?? newDoc);

    // Ensure the docId is set in the data map if it is null
    if (data['docId'] == null) data['docId'] = docId;

    final subDocRef = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc(docId);
    final docRef = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId);

    /// we need SetOptions(merge: true) to ensure increment or decrement
    await docRef.set({
      ApiConstants.metaValue: FieldValue.increment(metaValue ?? 0),
    }, SetOptions(merge: true));
    final subDocSnapshot = await subDocRef.get();

    if (subDocSnapshot.exists && subDocumentId != null) {
      await update(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: rootDocumentId,
        subCollectionPath: subCollectionPath,
        subDocumentId: docId,
        data: data,
      );
    } else {
      await subDocRef.set(data);
    }

    return data;
  }

  @override
  Future<void> update({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
    required Map<String, dynamic> data,
  }) async {
    final docRef = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc(subDocumentId);

    await docRef.update(data);
  }

  @override
  Future<void> delete({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
    double? metaValue,
  }) async {
    final subDocRef =
        _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc(subDocumentId);
    final docRef = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId);
    await docRef.set({
      ApiConstants.metaValue: FieldValue.increment(metaValue ?? 0),
    }, SetOptions(merge: true));
    await subDocRef.delete();
  }

  @override
  Future<int> countDocuments({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    QueryFilter? countQueryFilter,
  }) async {
    // Start with the base query as a Query<Map<String, dynamic>>
    Query<Map<String, dynamic>> query = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath);

    // Apply the filter if provided
    if (countQueryFilter != null) {
      query = query.where(
        countQueryFilter.field,
        isEqualTo: countQueryFilter.value,
      );
    }

    // Convert the query to a count query
    final countQuery = query.count();

    // Execute the count query
    final countSnapshot = await countQuery.get();

    // Return the count
    return countSnapshot.count ?? 0;
  }

  @override
  Future<List<Map<String, dynamic>>> saveAll({
    required List<Map<String, dynamic>> items,
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    double? metaValue,
  }) async {
    final addedItems = <Map<String, dynamic>>[];

    // Divide items into chunks of 500 using the provided chunkBy extension
    final chunks = items.chunkBy(500);

    // Process each chunk in its own batch
    for (final chunk in chunks) {
      final batch = _firestoreInstance.batch();

      for (final item in chunk) {
        // Ensure the document ID is set
        final docId = item.putIfAbsent(
          'docId',
          () => _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc().id,
        );

        // Create references for the sub-document and the main document
        final subDocRef = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc(docId);
        final docRef = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId);

        // Add set operations to the batch
        batch.set(subDocRef, item);
        batch.set(docRef, {ApiConstants.metaValue: metaValue}, SetOptions(merge: true));

        // Collect the processed item
        addedItems.add(item);
      }

      // Commit the batch for the current chunk
      await batch.commit();
    }

    return addedItems;
  }

  @override
  Future<double?> fetchMetaData(
      {required String rootCollectionPath,
      required String rootDocumentId,
      required String subCollectionPath,
      String? subDocumentId}) async {
    final docSnapshot = await _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).get();
    if (docSnapshot.exists) {
      return docSnapshot.data()![ApiConstants.metaValue];
    } else {
      throw Exception('Document not found');
    }
  }
}
