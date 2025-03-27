import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/account_type_dropdown.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
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
          title: Row(
            children: [
              Spacer(),
              Text(
                controller.isEditAccount ? controller.selectedAccount!.accName! : AppStrings.accountCard.tr,
              ),
              Spacer(),
              SizedBox(
                  width: 400,
                  child: CustomTextFieldWithoutIcon(
                      enabled: true,
                      textEditingController: TextEditingController()
                        ..text = controller.isEditAccount ? controller.selectedAccount!.id! : '')),
              Spacer(),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            spacing: 20,
            children: [
              AddAccountFormWidget(controller: controller),
              AccountTypeDropdown(accountSelectionHandler: controller.accountFromHandler),

              // Button to add a new customer
              AddCustomersWidget(),
              AddAccountButtonsWidget(controller: controller),
            ],
          ),
        ),
      );
    });
  }
}