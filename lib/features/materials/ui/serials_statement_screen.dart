import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../bill/controllers/bill/all_bills_controller.dart';

class SerialsStatementScreenScreen extends StatelessWidget {
  const SerialsStatementScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllBillsController>(
      builder: (controller) {
        return PlutoGridWithAppBar(
          title: controller.serialNumbersStatementScreenTitle,
          onLoaded: (e) {},
          onSelected: (event) {
            // String originId = event.row?.cells['originId']?.value;
            // controller.launchBondEntryBondScreen(context: context, originId: originId);
          },
          isLoading: controller.isLoadingPlutoGrid,
          tableSourceModels: controller.serialNumberStatements,
        );
      },
    );
  }
}