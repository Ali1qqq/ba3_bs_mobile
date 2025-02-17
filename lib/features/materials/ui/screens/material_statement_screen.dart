import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/mats_statement_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class MaterialStatementScreen extends StatelessWidget {
  const MaterialStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialsStatementController>(
      builder: (controller) {
        return PlutoGridWithAppBar(
          title: controller.screenTitle,
          onLoaded: (e) {},
          onSelected: (event) {
            // String originId = event.row?.cells['originId']?.value;
            // controller.launchBondEntryBondScreen(context: context, originId: originId);
          },
          isLoading: controller.isLoadingPlutoGrid,
          tableSourceModels: controller.matStatements,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${AppStrings.total.tr} :",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      controller.totalQuantity.toString(),
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}