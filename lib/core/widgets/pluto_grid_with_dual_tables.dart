import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/pluto/controllers/pluto_dual_table_controller.dart';

class PlutoGridWithDualTables extends StatelessWidget {
  final String title;
  final bool isLoading;
  final Widget? bottomChild; // Accept bottomChild

  const PlutoGridWithDualTables({
    super.key,
    required this.title,
    this.isLoading = false,
    this.bottomChild,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlutoDualTableController>(
      init: PlutoDualTableController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Credit Table (Left)
                            Expanded(
                              child: PlutoGrid(
                                key: controller.plutoKey,
                                columns: controller.generateColumns(false),
                                rows: controller.generateRows(controller.creditItems, false),
                                mode: PlutoGridMode.readOnly,
                              ),
                            ),
                            const SizedBox(width: 16), // Space between tables
                            // Debit Table (Right)
                            Expanded(
                              child: PlutoGrid(
                                key: controller.plutoKey,
                                columns: controller.generateColumns(true),
                                rows: controller.generateRows(controller.debitItems, true),
                                mode: PlutoGridMode.readOnly,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (bottomChild != null) bottomChild!, // Pass bottomChild here
                  ],
                ),
        );
      },
    );
  }
}
