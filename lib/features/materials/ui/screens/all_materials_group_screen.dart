import 'package:ba3_bs_mobile/features/materials/controllers/material_group_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class AllMaterialsGroupScreen extends StatelessWidget {
  const AllMaterialsGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialGroupController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: 'جميع المجموعات',
        isLoading: controller.isLoading,
        tableSourceModels: controller.materialGroups,
        onLoaded: (event) {},
        onSelected: (selectedRow) {
        },
      );
    });
  }
}
