import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bonds/all_bond_controller.dart';

AppBar bondLayoutAppBar(AllBondsController controller) {
  return AppBar(actions: [
    if (RoleItemType.administrator.hasAdminPermission)
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppButton(
          title: "تحميل السندات",
          onPressed: () => controller.fetchAllBondsLocal(),
        ),
      ),
  ]);
}
