import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../users_management/data/models/role_model.dart';
import '../../../controllers/cheques/all_cheques_controller.dart';

AppBar chequesLayoutAppBar() {
  return AppBar(
    actions: [
      if (RoleItemType.administrator.hasReadPermission)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppButton(
            title: AppStrings.downloadCheques.tr,
            onPressed: () => read<AllChequesController>().fetchAllChequesLocal(),
          ),
        ),
    ],
  );
}