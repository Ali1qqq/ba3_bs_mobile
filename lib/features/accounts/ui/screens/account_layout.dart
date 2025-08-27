import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/customer/controllers/customers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_menu_item.dart';

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
            _buildAppBarButton(AppStrings.downloadAccounts.tr, () {
              read<AccountsController>().fetchAllAccountsFromLocal(context);
            }),
            _buildAppBarButton(AppStrings.downloadCustomers.tr, () {
              read<CustomersController>().fetchAllCustomersFromLocal();
            }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            children: [
              buildAppMenuItem(
                icon: Icons.account_balance_wallet,
                title: AppStrings.viewAccounts.tr,
                onTap: () {
                  read<AccountsController>()
                    ..fetchAccounts()
                    ..navigateToAllAccountsScreen(context);
                },
              ),
              buildAppMenuItem(
                icon: Icons.receipt_long,
                title: AppStrings.accountStatement.tr,
                onTap: () {
                  read<AccountsController>().showAccountFilterDialog(context: context);
                  // showDialog<String>(
                  //   context:context ,
                  //   builder: (BuildContext context) =>
                  //       showAccountFilterDialog(context),
                  // );
                },
              ),
              buildAppMenuItem(
                icon: Icons.person_add_alt,
                title: AppStrings.addAccount.tr,
                onTap: () {
                  read<AccountsController>().navigateToAddOrUpdateAccountScreen(context: context);
                },
              ),
              buildAppMenuItem(
                icon: Icons.insert_chart_outlined,
                title: AppStrings.finalAccounts.tr,
                onTap: () {
                  read<AccountsController>().navigateToFinalAccountsScreen(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: AppButton(
        title: title,
        width: 140,
        onPressed: onPressed,
      ),
    );
  }
}