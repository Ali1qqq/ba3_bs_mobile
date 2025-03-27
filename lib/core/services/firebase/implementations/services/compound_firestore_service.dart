import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pool/pool.dart';

import '../../../../../features/migration/controllers/migration_controller.dart';
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

    log('rootCollectionPath $rootCollectionPath, rootDocumentId $rootDocumentId, subcollectionPath $subCollectionPath',
        name: 'fetchAll CompoundFirestoreService');
    return (await querySnapshot).docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWhere<V>({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? field,
    V? value,
    DateFilter? dateFilter,
  }) async {
    // If both field and dateFilter are null, return an empty list
    if ((field == null || value == null) && dateFilter == null) {
      log("fetchWhere: No filtering applied, returning empty list.");
      return [];
    }

    // Initialize the base query
    Query<Map<String, dynamic>> query = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath);

    // Apply field filter if field and value are provided
    if (field != null && value != null) {
      query = query.where(field, isEqualTo: value);
    }

    // Apply date filter if provided
    if (dateFilter != null) {
      query = _applyDateFilter(query, dateFilter);
    }

    log('rootCollectionPath $rootCollectionPath, rootDocumentId $rootDocumentId, subcollectionPath $subCollectionPath',
        name: 'fetchWhere CompoundFirestoreService');
    // Execute the query
    final snapshot = await query.get();

    log("fetchWhere: Found ${snapshot.docs.length} documents.");

    if (snapshot.docs.isEmpty) {
      throw Exception("No results found for query in '$subCollectionPath' with field '$field' and value '$value'.");
    }

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

// Helper method to apply the date filter to the query
  Query<Map<String, dynamic>> _applyDateFilter(Query<Map<String, dynamic>> query, DateFilter dateFilter) {
    // The start date/time for the range filter (inclusive).
    final start = DateTime(dateFilter.range.start.year, dateFilter.range.start.month, dateFilter.range.start.day);

    // Adjust the end date to include the entire day up to the last millisecond (23:59:59.999).
    final end = DateTime(dateFilter.range.end.year, dateFilter.range.end.month, dateFilter.range.end.day, 23, 59, 59, 999);

    // Check if start and end dates are the same
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      log("fetchWhere: Applying full-day filter for ${start.toIso8601String()}.");
      return query.where(dateFilter.dateFieldName, isGreaterThanOrEqualTo: start).where(dateFilter.dateFieldName, isLessThanOrEqualTo: end);
    }

    // Apply the date range filters to the query.
    // - Greater than or equal to the start ensures we capture all entries from the start date onward.
    // - Less than or equal to the adjusted end ensures we include all entries up to the end of the specified date.
    // Apply normal range filtering
    return query
        .where(dateFilter.dateFieldName, isGreaterThanOrEqualTo: dateFilter.range.start)
        .where(dateFilter.dateFieldName, isLessThanOrEqualTo: end);
  }

  @override
  Future<Map<String, dynamic>> fetchById({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    String? subDocumentId,
  }) async {
    log('rootCollectionPath $rootCollectionPath, rootDocumentId $rootDocumentId, subcollectionPath $subCollectionPath, subDocumentId $subDocumentId',
        name: 'fetchById CompoundFirestoreService');

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
    try {
      if (dateBaseGuard(rootCollectionPath)) {
        log('Migration guard triggered, skipping add operation for [$rootCollectionPath].', name: 'Add CompoundFirestoreService');
        return {};
      }

      log('$data', name: 'data CompoundFirestoreService');

      // Generate or use existing document ID
      final newDoc = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc().id;

      // Use the provided subDocumentId or generate a new one if not provided
      final docId = subDocumentId ?? (data['docId'] ?? newDoc);

      // Ensure the docId is set in the data map if it is null
      if (data['docId'] == null) data['docId'] = docId;

      log('rootCollectionPath $rootCollectionPath, rootDocumentId $rootDocumentId, subcollectionPath $subCollectionPath, subDocumentId $docId',
          name: 'Add CompoundFirestoreService');

      final subDocRef = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc(docId);
      final docRef = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId);

      /// we need SetOptions(merge: true) to ensure increment or decrement
      await docRef.set(
        {
          ApiConstants.metaValue: FieldValue.increment(metaValue ?? 0),
        },
        SetOptions(merge: true),
      );

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
        log('set subDocRef.path ${subDocRef.path}', name: 'Add CompoundFirestoreService');
        await subDocRef.set(data);
      }

      return data;
    } catch (e) {
      log('Error in add: $e', name: 'Add CompoundFirestoreService');
      rethrow;
    }
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
    log('rootCollectionPath $rootCollectionPath, rootDocumentId $rootDocumentId, subcollectionPath $subCollectionPath, subDocumentId $subDocumentId',
        name: 'delete CompoundFirestoreService');

    if (dateBaseGuard(rootCollectionPath)) {
      log('Migration guard triggered, skipping delete operation for [$rootCollectionPath].', name: 'delete CompoundFirestoreService');
      return;
    }

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
    log('rootCollectionPath $rootCollectionPath, rootDocumentId $rootDocumentId, subcollectionPath $subCollectionPath',
        name: 'Add CompoundFirestoreService');
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
  Future<List<Map<String, dynamic>>> addAll({
    required List<Map<String, dynamic>> items,
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subCollectionPath,
    double? metaValue,
  }) async {
    log('rootCollectionPath $rootCollectionPath, rootDocumentId $rootDocumentId, subcollectionPath $subCollectionPath',
        name: 'AddAll CompoundFirestoreService');

    if (dateBaseGuard(rootCollectionPath)) {
      log('Migration guard triggered, skipping addAll operation for [$rootCollectionPath].', name: 'AddAll CompoundFirestoreService');
      return [];
    }

    // 1. Split items into sub-lists of size up to 500
    final chunks = items.chunkBy(500);

    final int maxConcurrency = 5;

    // 2. Create a Pool to limit concurrency
    final pool = Pool(maxConcurrency);

    // 3. Map each chunk to a future that writes the chunk in one batch
    final futures = chunks.map((chunk) => pool.withResource(() async {
          final batch = _firestoreInstance.batch();
          final chunkAdded = <Map<String, dynamic>>[];

          for (final item in chunk) {
            // Ensure the document ID is set
            final docId = item.putIfAbsent(
              'docId',
              () => _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc().id,
            );

            // Create references for the sub-document and the main document
            final subDocRef =
                _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId).collection(subCollectionPath).doc(docId);

            final docRef = _firestoreInstance.collection(rootCollectionPath).doc(rootDocumentId);

            // Add set operations to the batch
            batch.set(subDocRef, item);
            batch.set(docRef, {ApiConstants.metaValue: metaValue}, SetOptions(merge: true));

            // Collect the processed item for return
            chunkAdded.add(item);
          }

          // Commit this chunk’s batch
          await batch.commit();
          return chunkAdded;
        }));

    // 4. Kick off all chunk writes in parallel, respecting concurrency limit
    final results = await Future.wait(futures);

    // 5. Close the pool (clean up) and flatten results
    await pool.close();

    log('addAll end');

    return results.flatten();
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