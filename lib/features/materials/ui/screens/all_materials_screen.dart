import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../controllers/material_controller.dart';

class AllMaterialsScreen extends StatelessWidget {
  const AllMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: AppStrings.allMaterials.tr,
        isLoading: controller.isLoading,
        tableSourceModels: controller.materials,
        onLoaded: (event) {},
        onSelected: (selectedRow) {
          String? matId = selectedRow.row?.cells[AppConstants.materialIdFiled]?.value;
          read<MaterialController>().navigateToAddOrUpdateMaterialScreen(matId: matId, context: context);
        },
      );
    });
  }
}