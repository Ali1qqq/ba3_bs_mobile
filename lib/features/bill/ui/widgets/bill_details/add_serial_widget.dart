import 'package:flutter/material.dart';

import '../../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../materials/data/models/materials/material_model.dart';

class AddSerialWidget extends StatefulWidget {
  final IPlutoController plutoController;
  final int serialCount;
  final MaterialModel materialModel;

  const AddSerialWidget({
    super.key,
    required this.plutoController,
    required this.serialCount,
    required this.materialModel,
  });

  @override
  State<AddSerialWidget> createState() => _AddSerialWidgetState();
}

class _AddSerialWidgetState extends State<AddSerialWidget> {
  @override
  void initState() {
    // Initialize controllers for the specific material id
    widget.plutoController.initSerialControllers(widget.materialModel, widget.serialCount);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the controllers for the given matId.
    final serialsControllers = widget.plutoController.serialControllers[widget.materialModel] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Serials'),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: serialsControllers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: serialsControllers[index],
              decoration: InputDecoration(
                labelText: 'Serial ${index + 1}',
                border: const OutlineInputBorder(),
              ),
            ),
          );
        },
      ),
    );
  }
}
