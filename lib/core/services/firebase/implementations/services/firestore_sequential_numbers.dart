import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

mixin FirestoreSequentialNumbers {
  final FirebaseFirestore _firestoreInstance = read<FirebaseFirestore>();

  final String _parentCollection = ApiConstants.sequentialNumbers;

  Future<EntitySequence> fetchAndIncrementEntityNumber(String category, String entityType) async {
    final docRef = _firestoreInstance
        .collection(_parentCollection) // Parent collection
        .doc(category); // Document for category (e.g., "bills", "bonds")

    // Fetch the current document
    final snapshot = await docRef.get();

    // entityType Document for entity type (e.g., "purchase", "sales")
    if (!snapshot.exists) {
      // Initialize the document with the first entry for this entityType
      await docRef.set({
        entityType: {
          ApiConstants.type: entityType,
          ApiConstants.lastNumber: 1,
        },
      });
      return EntitySequence(currentNumber: null, nextNumber: 1);
    }

    // Get the current data for the document
    final data = snapshot.data();
    final entityData = data?[entityType] as Map<String, dynamic>?;

    if (entityData == null) {
      // Initialize the entry for this entityType if it doesn't exist
      await docRef.update({
        entityType: {
          ApiConstants.type: entityType,
          ApiConstants.lastNumber: 1,
        },
      });
      return EntitySequence(currentNumber: null, nextNumber: 1);
    }

    // Extract the `lastNumber` and increment it
    final lastNumber = entityData[ApiConstants.lastNumber] as int? ?? 0;

    final newNumber = lastNumber + 1;

    // Update the document with the new number for this entityType
    await docRef.update({
      '$entityType.${ApiConstants.lastNumber}': newNumber,
    });

    return EntitySequence(currentNumber: lastNumber == 0 ? null : lastNumber, nextNumber: newNumber);
  }

  Future<void> setLastUsedNumber(String category, String entityType, int number) async {
    final docRef = _firestoreInstance
        .collection(_parentCollection) // Parent collection
        .doc(category); // Document for category (e.g., "bills", "bonds")

    await docRef.set(
      {
        entityType: {
          ApiConstants.type: entityType,
          ApiConstants.lastNumber: number,
        },
      },
      SetOptions(merge: true),
    );
  }

  Future<void> decrementLastNumber(String category, String entityType, {int? number}) async {
    final docRef = _firestoreInstance.collection(_parentCollection).doc(category);

    await docRef.set(
      {
        entityType: {
          ApiConstants.lastNumber: FieldValue.increment(number ?? -1),
        },
      },
      SetOptions(merge: true),
    );
  }

  Future<int> getLastNumber({required String category, required String entityType, int? number}) async {
    if (number != null) {
      return number;
    }
    final docRef = _firestoreInstance
        .collection(_parentCollection) // Parent collection
        .doc(category); // Document for category (e.g., "bills", "bonds")

    log('docRef ${docRef.path}', name: 'docRef');

    // Fetch the current document
    final snapshot = await docRef.get();

    // entityType Document for entity type (e.g., "purchase", "sales")
    if (!snapshot.exists) {
      return 0;
    }

    // Get the current data for the document
    final data = snapshot.data();
    final entityData = data?[entityType] as Map<String, dynamic>?;

    if (entityData == null) {
      return 0;
    }

    // Extract the `lastNumber` and increment it
    final lastNumber = entityData[ApiConstants.lastNumber] as int? ?? 0;

    return lastNumber;
  }
}

class EntitySequence {
  final int? currentNumber;
  final int nextNumber;

  EntitySequence({
    required this.currentNumber,
    required this.nextNumber,
  });
}