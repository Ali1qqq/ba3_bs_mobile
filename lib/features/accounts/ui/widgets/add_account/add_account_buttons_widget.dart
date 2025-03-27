import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/accounts_controller.dart';

class AddAccountButtonsWidget extends StatelessWidget {
  final AccountsController controller;

  const AddAccountButtonsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
      children: [
        AppButton(
            title: controller.isEditAccount ? AppStrings.edit.tr : AppStrings.add.tr,
            onPressed: () {
              controller.saveOrUpdateAccount();
            }),
        if (controller.isEditAccount)
          AppButton(
              title: AppStrings.delete.tr,
              onPressed: () {
                controller.deleteAccount();
              }),
      ],
    );
  }
}