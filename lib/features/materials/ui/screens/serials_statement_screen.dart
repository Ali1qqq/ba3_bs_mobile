import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class SerialsStatementScreenScreen extends StatelessWidget {
  const SerialsStatementScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllBillsController>(
      builder: (controller) {
        return PlutoGridWithAppBar(
          title: controller.serialNumbersStatementScreenTitle,
          onLoaded: (e) {},
          onSelected: (PlutoGridOnSelectedEvent event) => controller.onSerialSelected(event, context),
          isLoading: controller.isLoadingPlutoGrid,
          tableSourceModels: controller.serialNumberStatements,
        );
      },
    );
  }
}