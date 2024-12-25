import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class AllBillsScreen extends StatelessWidget {
  const AllBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllBillsController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: 'جميع الفواتير',
        onLoaded: (e) {},
        onSelected: (event) {
          String billId = event.row?.cells['billId']?.value;
          controller.openBillDetailsById(billId, context);
        },
        isLoading: controller.isLoading,
        tableSourceModels: controller.bills,
        icon: Icons.outbox,
        onIconPressed: controller.exportBillsJsonFile,
      );
    });
  }
}
