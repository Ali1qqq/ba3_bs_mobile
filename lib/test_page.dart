import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  bool isLoading = false;
  String message = "";

  Future<void> migrateUsers() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    final firebaseApp = Firebase.app();
    FirebaseFirestore firestoreInstance =
        FirebaseFirestore.instanceFor(app: firebaseApp, databaseId: "test-eu");

    try {
      final usersSnapshot = await firestoreInstance.collection('users').get();

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();

        List<dynamic> oldHolidays = data['userHolidays'] ?? [];

        /// إذا ما تحولوا بعد
        if (oldHolidays.isNotEmpty && oldHolidays.first is String) {
          List<Map<String, dynamic>> newHolidays = oldHolidays.map((date) {
            return {
              "type": "annual",
              "date": date,
            };
          }).toList();

          await doc.reference.update({
            "userHolidays": newHolidays,
          });
        }
      }

      message = "Migration completed successfully ✅";
    } catch (e) {
      message = "Error: $e";
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users Migration"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) const CircularProgressIndicator(),
              if (!isLoading)
                ElevatedButton(
                  onPressed: migrateUsers,
                  child: const Text("Run Migration"),
                ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
