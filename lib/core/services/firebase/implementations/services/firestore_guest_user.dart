import 'dart:developer';

import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

mixin FirestoreGuestUser {
  /// Reference to the guest user collection in Firestore.
  final guestCollection = FirebaseFirestore.instance.collection(ApiConstants.guestUser);

  /// Creates a guest user document in Firestore.
  ///
  /// [guestData]: A map containing the guest user details to store.
  Future<void> createGuestUser(String documentId) async {
    try {
      await guestCollection.doc(documentId).set({
        'docId': documentId,
        'show': true,
      });
      log('Guest user created successfully in $documentId collection.');
    } catch (e, stacktrace) {
      log('Error creating guest user: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  Future<void> updateGuestUser(String documentId, {required bool visible}) async {
    try {
      await guestCollection.doc(documentId).set({
        'docId': documentId,
        'show': visible,
      });
      log('Guest user created successfully in $documentId collection.');
    } catch (e, stacktrace) {
      log('Error creating guest user: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  /// Fetches the guest user document from Firestore.
  ///
  /// Returns a map containing the guest user data, or `null` if the document doesn't exist.
  Future<Map<String, dynamic>?> fetchGuestUser(String documentId) async {
    try {
      final docSnapshot = await guestCollection.doc(documentId).get();
      if (docSnapshot.exists) {
        log('Guest user fetched successfully.');
        return docSnapshot.data();
      } else {
        log('Guest user document not found in $documentId collection.');
        return null;
      }
    } catch (e, stacktrace) {
      log('Error fetching guest user: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  /// Checks if the guest user is marked as visible by the "show" field.
  ///
  /// Returns `true` if the "show" field exists and is `true`, otherwise `false`.
  Future<bool> isGuestUserEnabled(String documentId) async {
    try {
      final guestData = await fetchGuestUser(documentId);
      final isVisible = guestData?['show'] == true;
      log('Guest user visibility: $isVisible');
      return isVisible;
    } catch (e, stacktrace) {
      log('Error checking guest user visibility: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  /// Deletes the guest user document from Firestore.
  Future<void> deleteGuestUser(String documentId) async {
    try {
      await guestCollection.doc(documentId).delete();
      log('Guest user document deleted successfully from $documentId collection.');
    } catch (e, stacktrace) {
      log('Error deleting guest user: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }
}
