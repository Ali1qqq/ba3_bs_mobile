import 'package:flutter/material.dart';

class BlockedApp extends StatelessWidget {
  const BlockedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              '⛔ التطبيق غير متاح حاليًا.\nيرجى المحاولة لاحقًا.',
              style: TextStyle(fontSize: 20, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
