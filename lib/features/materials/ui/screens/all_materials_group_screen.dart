import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_group_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../controllers/material_controller.dart';

class AllMaterialsGroupScreen extends StatelessWidget {
  const AllMaterialsGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialGroupController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: AppStrings.allGroups.tr,
        isLoading: controller.isLoading,
        tableSourceModels: controller.materialGroups,
        onLoaded: (event) {},
        onSelected: (selectedRow) {
          String? groupGuid = selectedRow.row?.cells[AppConstants.materialGroupIdFiled]?.value;
          read<MaterialController>().navigateToAllMaterialScreen(groupGuid: groupGuid, context: context);
        },
      );
    });
  }
}