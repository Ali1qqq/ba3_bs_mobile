import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class PendingBillsScreen extends StatelessWidget {
  const PendingBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllBillsController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: 'الفواتير المعلقة',
        onLoaded: (e) {},
        onSelected: (event) {},
        isLoading: controller.isPendingBillsLoading,
        tableSourceModels: controller.pendingBills,
      );
    });
  }
}
