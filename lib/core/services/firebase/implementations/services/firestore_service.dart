// Firebase-Specific Implementation

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/i_remote_database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pool/pool.dart';
import 'package:uuid/uuid.dart';

import '../../../../../features/migration/controllers/migration_controller.dart';
import '../../../../models/date_filter.dart';

// FirebaseFirestoreService Implementation
class FireStoreService extends IRemoteDatabaseService<Map<String, dynamic>> {
  final FirebaseFirestore _firestoreInstance;

  FireStoreService(FirebaseFirestore instance) : _firestoreInstance = instance;

  @override
  Future<List<Map<String, dynamic>>> fetchAll({required String path}) async {
    final snapshot = await _firestoreInstance.collection(path).get();
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
      _applyFilters(_firestoreInstance.collection(path), queryFilters),
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
    final doc = await _firestoreInstance.collection(path).doc(documentId).get();
    if (doc.exists) {
      return doc.data()!;
    } else {
      throw Exception('Document not found');
    }
  }

  @override
  Future<void> delete({required String path, String? documentId, String? mapFieldName}) async {
    if (dateBaseGuard(path)) {
      log('Migration guard triggered, skipping delete operation for path [$path].', name: 'delete CompoundFirestoreService');
      return;
    }

    if (mapFieldName != null) {
      // If mapFieldName is provided, delete the specific map field
      await _firestoreInstance.collection(path).doc(documentId).update({
        mapFieldName: FieldValue.delete(),
      });
    } else {
      // If mapFieldName is null, delete the entire document
      await _firestoreInstance.collection(path).doc(documentId).delete();
    }
  }

  @override
  Future<Map<String, dynamic>> add({required Map<String, dynamic> data, required String path, String? documentId}) async {
    if (dateBaseGuard(path)) {
      log('Migration guard triggered, skipping add operation for path [$path].', name: 'add CompoundFirestoreService');
      return {};
    }
    Uuid uuid = Uuid();

    final newDoc = uuid.v4();
    // final newDoc = _firestoreInstance.collection(path).doc().id;

    // Use the provided document ID or generate a new one if not provided
    final docId = documentId ?? (data['docId'] ?? newDoc);

    // Ensure the docId is set in the data map if it is null
    if (data['docId'] == null) data['docId'] = docId;

    final docRef = _firestoreInstance.collection(path).doc(docId);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists && documentId != null) {
      await update(path: path, documentId: docId, data: data);
    } else {
      await docRef.set(data);
    }

    log('$data', name: 'Add FireStoreService');
    return data;
  }

  @override
  Future<void> update({required String path, String? documentId, required Map<String, dynamic> data}) async {
    log('update path $path, $documentId');
    await _firestoreInstance.collection(path).doc(documentId).update(data);
  }

  @override
  Future<List<Map<String, dynamic>>> addAll({
    required String path,
    required List<Map<String, dynamic>> data,
  }) async {
    if (dateBaseGuard(path)) {
      log('Migration guard triggered, skipping addAll operation for path [$path].', name: 'addAll CompoundFirestoreService');
      return [];
    }

    // 1. Break the data into chunks of up to 500 items
    final chunks = data.chunkBy(500);

    final int maxConcurrency = 5;

    // 2. Create a Pool to limit concurrency (e.g., 5 commits at once)
    final pool = Pool(maxConcurrency);
    final futures = <Future<List<Map<String, dynamic>>>>[];

    for (final chunk in chunks) {
      // Wrap each chunk commit in withResource()
      final future = pool.withResource(
        () async {
          final batch = _firestoreInstance.batch();

          final chunkAdded = <Map<String, dynamic>>[];

          for (final item in chunk) {
            final docId = item['docId'] ?? _firestoreInstance.collection(path).doc().id;

            item['docId'] = docId;

            final docRef = _firestoreInstance.collection(path).doc(docId);

            batch.set(docRef, item, SetOptions(merge: true));

            chunkAdded.add(item);
          }

          await batch.commit();

          return chunkAdded;
        },
      );

      futures.add(future);
    }

    // 3. Wait for all futures to complete, then close the pool
    final results = await Future.wait(futures);

    await pool.close();

    // 4. Flatten and return
    return results.flatten();
  }

  @override
  Stream<Map<String, dynamic>> subscribeToDoc({required String path, String? documentId}) {
    if (documentId == null || documentId.isEmpty) {
      throw ArgumentError("Document ID cannot be null or empty");
    }

    final documentStream = _firestoreInstance.collection(path).doc(documentId).snapshots();

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

  @override
  Future<List<Map<String, dynamic>>> batchUpdateWithArrayUnionOnMap({
    required String path,
    required List<Map<String, dynamic>> items,
    required String docIdField,
    required String nestedFieldPath,
  }) async {
    final batch = _firestoreInstance.batch();

    // List to track the items being processed
    final processedItems = <Map<String, dynamic>>[];

    for (final item in items) {
      // Extract the document ID
      final docId = item[docIdField];

      if (docId == null) {
        throw ArgumentError('Document ID is missing in one of the items');
      }

      // Reference to the document
      final docRef = _firestoreInstance.collection(path).doc(docId);

      // Check if the document exists
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // Create the document with initial structure
        final initialData = {
          docIdField: docId,
          nestedFieldPath: item[nestedFieldPath],
        };
        batch.set(docRef, initialData);
        processedItems.add(initialData);
      } else {
        // Update the document using arrayUnion for nested fields
        final nestedData = item[nestedFieldPath] as Map<String, dynamic>;

        nestedData.forEach((key, value) {
          if (value is List) {
            batch.update(docRef, {
              '$nestedFieldPath.$key': FieldValue.arrayUnion(value),
            });
          }
        });

        processedItems.add(item);
      }
    }

    // Commit the batch operation
    await batch.commit();

    return processedItems;
  }

  @override
  Future<List<Map<String, dynamic>>> batchUpdateWithArrayUnionOnList({
    required String path,
    required List<Map<String, dynamic>> items,
    required String docIdField,
    required String nestedFieldPath,
  }) async {
    final batch = _firestoreInstance.batch();
    final processedItems = <Map<String, dynamic>>[];

    for (final item in items) {
      // Extract the document ID dynamically
      final docId = item[docIdField];
      if (docId == null) {
        throw ArgumentError('Document ID is missing in one of the items');
      }

      // Reference to the document
      final docRef = _firestoreInstance.collection(path).doc(docId);

      // Check if the document exists
      final docSnapshot = await docRef.get();

      // Extract transactions safely
      final transactions = (item[nestedFieldPath] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];

      if (!docSnapshot.exists) {
        // Remove the `docIdField` key to avoid duplication in Firestore
        final itemWithoutTransactions = Map<String, dynamic>.from(item)..remove(nestedFieldPath);

        // Create the document with all fields + transactions
        batch.set(
          docRef,
          {
            ...itemWithoutTransactions, // Store all dynamic fields
            nestedFieldPath: transactions, // Save transactions as an array
          },
        );

        processedItems.add(item);
      } else {
        // Prepare update data dynamically without overwriting non-nested fields
        final updateData = <String, dynamic>{};

        item.forEach((key, value) {
          if (key == nestedFieldPath) {
            // Apply arrayUnion only for the nested transactions list
            updateData[key] = FieldValue.arrayUnion(transactions);
          } else if (key != docIdField) {
            // Keep all other fields updated normally (without arrayUnion)
            updateData[key] = value;
          }
        });

        // Perform batch update
        batch.update(docRef, updateData);
        processedItems.add(item);
      }
    }

    // Commit the batch operation
    await batch.commit();
    return processedItems;
  }

  @override
  Future<String> uploadImage({required String imagePath, required String path}) async {
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64String = base64Encode(imageBytes);

    String docId = DateTime.now().millisecondsSinceEpoch.toString();

    await _firestoreInstance
        .collection(path)
        .doc(docId)
        .set({"image_base64": base64String, "uploaded_at": DateTime.now().toIso8601String()});

    return docId; // Return document ID as a reference
  }

  @override
  Future<String?> fetchImage(String path, String docId) async {
    DocumentSnapshot snapshot = await _firestoreInstance.collection(path).doc(docId).get();

    if (snapshot.exists && snapshot.data() != null) {
      return (snapshot.data() as Map<String, dynamic>)['image_base64'] as String?;
    }
    return null;
  }
}