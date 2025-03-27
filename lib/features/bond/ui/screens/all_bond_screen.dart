import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class AllBondScreen extends StatelessWidget {
  const AllBondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllBondsController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: AppStrings.allBonds.tr,
        onLoaded: (e) {},
        onSelected: (event) {
          String bondId = event.row?.cells[AppConstants.bondIdFiled]?.value;
          BondType bondType = BondType.byTypeGuide(event.row?.cells['type']?.value);
          log('bondId : $bondId');
          controller.openBondDetailsById(bondId, context, bondType);
        },
        isLoading: controller.isBondsLoading,
        tableSourceModels: controller.bonds,
      );
    });
  }
}