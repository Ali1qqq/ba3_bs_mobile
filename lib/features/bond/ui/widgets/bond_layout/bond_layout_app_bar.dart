import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../users_management/data/models/role_model.dart';

AppBar bondLayoutAppBar(AllBondsController controller) {
  return AppBar(actions: [
    if (RoleItemType.administrator.hasAdminPermission)
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppButton(
          title: AppStrings.downloadBonds.tr,
          onPressed: () => controller.fetchAllBondsLocal(),
        ),
      ),
  ]);
}