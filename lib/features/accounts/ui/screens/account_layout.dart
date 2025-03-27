import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/app_menu_item.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/customer/controllers/customers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/account_filter_dialog.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_button.dart';

class AccountLayout extends StatelessWidget {
  const AccountLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.accounts.tr),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppButton(
                title: AppStrings.downloadAccounts.tr,
                onPressed: () => read<AccountsController>().fetchAllAccountsFromLocal(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppButton(
                title: AppStrings.downloadCustomers.tr,
                onPressed: () => read<CustomersController>().fetchAllCustomersFromLocal(),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            AppMenuItem(
              text: AppStrings.viewAccounts.tr,
              onTap: () {
                read<AccountsController>()
                  ..fetchAccounts()
                  ..navigateToAllAccountsScreen(context);
              },
            ),
            AppMenuItem(
              text: AppStrings.accountStatement.tr,
              onTap: () {
                showDialog<String>(context: Get.context!, builder: (BuildContext context) => showAccountFilterDialog(context));
              },
            ),
            AppMenuItem(
              text: AppStrings.addAccount.tr,
              onTap: () {
                read<AccountsController>().navigateToAddOrUpdateAccountScreen(context: context);
              },
            ),
            AppMenuItem(
              text: AppStrings.finalAccounts.tr,
              onTap: () {
                read<AccountsController>().navigateToFinalAccountsScreen(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}