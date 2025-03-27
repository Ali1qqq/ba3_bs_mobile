import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../helper/extensions/getx_controller_extensions.dart';

class FirestoreUploader {
  final FirebaseFirestore _firestoreInstance = read<FirebaseFirestore>();

  /// Concurrent approach: uploads all items in parallel batches with progress tracking.
  Future<void> concurrently({
    required List<Map<String, dynamic>> data,
    required String collectionPath,
    required void Function(double progress) onProgress,
    int chunkSize = 50, // Firestore batch limit
  }) async {
    final chunks = List.generate(
      (data.length / chunkSize).ceil(),
      (i) => data.skip(i * chunkSize).take(chunkSize).toList(),
    );

    int uploadedItems = 0;

    // Process all chunks in parallel
    await Future.wait(
      chunks.map(
        (chunk) async {
          await _addBatch(chunk, collectionPath);
          uploadedItems += chunk.length;
          onProgress(uploadedItems / data.length); // Report progress
        },
      ),
    );
  }

  /// Sequential approach: uploads items batch by batch in order with progress tracking.
  Future<void> sequentially({
    required List<Map<String, dynamic>> data,
    required String collectionPath,
    required void Function(double progress) onProgress,
    int batchSize = 50, //Firestore batch limit
  }) async {
    int counter = 1;
    WriteBatch batch = _firestoreInstance.batch();

    for (int i = 0; i < data.length; i++) {
      final docId = data[i].putIfAbsent('docId', () => _firestoreInstance.collection(collectionPath).doc().id);

      final docRef = _firestoreInstance.collection(collectionPath).doc(docId);
      batch.set(docRef, data[i]);

      // Commit batch every 50 documents or at the end
      if ((i + 1) % batchSize == 0 || i == data.length - 1) {
        log('Start upload batch $counter');
        await batch.commit();
        log('Finish upload batch $counter');
        batch = _firestoreInstance.batch(); // Reset batch for the next set

        counter++;
      }

      onProgress((i + 1) / data.length); // Report progress
    }
  }

  /// Helper method to commit a batch of items.
  Future<void> _addBatch(List<Map<String, dynamic>> data, String collectionPath) async {
    WriteBatch batch = _firestoreInstance.batch();

    for (Map<String, dynamic> item in data) {
      final docId = item.putIfAbsent('docId', () => _firestoreInstance.collection(collectionPath).doc().id);
      final docRef = _firestoreInstance.collection(collectionPath).doc(docId);
      batch.set(docRef, item);
    }

    await batch.commit();
  }
}
