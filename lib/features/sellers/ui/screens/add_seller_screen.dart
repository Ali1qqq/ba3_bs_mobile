import 'package:flutter/material.dart';

class AddSellerScreen extends StatelessWidget {
  const AddSellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('بائع جديد'),
      ),
      body: Center(
        child: Text('Add new sellers'),
      ),
    );
  }
}
