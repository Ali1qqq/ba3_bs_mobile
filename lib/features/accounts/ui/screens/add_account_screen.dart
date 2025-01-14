import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../../core/widgets/account_type_dropdown.dart';
import '../widgets/add_account/add_account_buttons_widget.dart';
import '../widgets/add_account/add_account_form_widget.dart';

class AddAccountScreen extends StatelessWidget {
  const AddAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountsController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            controller.isFromHandler ? controller.selectedAccount!.accName! : "بطاقة حساب",
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
