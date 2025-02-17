import 'package:ba3_bs_mobile/core/widgets/app_menu_item.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/dialogs/Account_Option_Dialog.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';

class AccountLayout extends StatelessWidget {
  const AccountLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(
          children: [
            AppMenuItem(
              text: AppStrings.viewAccounts.tr,
              onTap: () {
                read<AccountsController>()
                  ..fetchAccounts()
                  ..navigateToAllAccountsScreen();
              },
            ),
            AppMenuItem(
              text: AppStrings.accountStatement.tr,
              onTap: () {
                showDialog<String>(context: Get.context!, builder: (BuildContext context) => accountOptionDialog(context));
              },
            ),
            AppMenuItem(
              text: AppStrings.addAccount.tr,
              onTap: () {
                read<AccountsController>().navigateToAddOrUpdateAccountScreen();
              },
            ),
          ],
        ),
      ),
    );
  }
}