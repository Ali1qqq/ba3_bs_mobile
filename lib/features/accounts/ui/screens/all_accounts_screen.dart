import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../controllers/accounts_controller.dart';

class AllAccountScreen extends StatelessWidget {
  const AllAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountsController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: AppStrings.allAccounts.tr,
        onLoaded: (e) {},
        onSelected: (p0) {
          final String accId = p0.row?.cells[AppConstants.accountIdFiled]?.value;

          controller.navigateToAddOrUpdateAccountScreen(accountId: accId, context: context);
        },
        isLoading: controller.isLoading,
        tableSourceModels: controller.accounts,
      );
    });
  }
}