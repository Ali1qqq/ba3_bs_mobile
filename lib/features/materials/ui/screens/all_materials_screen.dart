import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../controllers/material_controller.dart';

class AllMaterialsScreen extends StatelessWidget {
  const AllMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: "جميع المواد",
        isLoading: controller.isLoading,
        tableSourceModels: controller.materials,
        onLoaded: (event) {},
        onSelected: (cell) {},
      );
    });
  }
}
