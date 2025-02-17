import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/account_type_dropdown.dart';
import '../widgets/add_account/add_account_buttons_widget.dart';
import '../widgets/add_account/add_account_form_widget.dart';
import '../widgets/add_account/add_customers_widget.dart';

class AddAccountScreen extends StatelessWidget {
  const AddAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountsController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            controller.isEditAccount ? controller.selectedAccount!.accName! : AppStrings.accountCard.tr,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            spacing: 20,
            children: [
              AddAccountFormWidget(
                controller: controller,
              ),
              // Button to add a new customer
              AddCustomersWidget(),
              AccountTypeDropdown(accountSelectionHandler: controller.accountFromHandler),
              AddAccountButtonsWidget(
                controller: controller,
              )
            ],
          ),
        ),
      );
    });
  }
}