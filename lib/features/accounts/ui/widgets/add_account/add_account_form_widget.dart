import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../../bill/ui/widgets/bill_shared/form_field_row.dart';
import '../../../controllers/accounts_controller.dart';

class AddAccountFormWidget extends StatelessWidget {
  const AddAccountFormWidget({super.key, required this.controller});

  final AccountsController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.accountFromHandler.formKey,
      child: Column(
        spacing: 20,
        children: [
          FormFieldRow(
            firstItem: TextAndExpandedChildField(
              label: AppStrings.accountName.tr,
              child: CustomTextFieldWithoutIcon(
                validator: (value) => controller.accountFromHandler.defaultValidator(value, "اسم الحساب"),
                textEditingController: controller.accountFromHandler.nameController,
              ),
            ),
            secondItem: TextAndExpandedChildField(
              label: AppStrings.latinAccountName.tr,
              child: CustomTextFieldWithoutIcon(
                suffixIcon: const SizedBox(),
                textEditingController: controller.accountFromHandler.latinNameController,
              ),
            ),
          ),
          FormFieldRow(
            firstItem: SearchableAccountField(
              textEditingController: controller.accountFromHandler.accParentName,
              label: AppStrings.fatherAccount.tr,
              onSubmitted: (text) async {
                AccountModel? accountModel = await controller.openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  controller.setAccountParent(accountModel);
                }
              },
            ),
            secondItem: TextAndExpandedChildField(
              label: AppStrings.accountCode.tr,
              child: CustomTextFieldWithoutIcon(
                suffixIcon: const SizedBox(),
                validator: (value) => controller.accountFromHandler.defaultValidator(value, "رمز الحساب"),
                textEditingController: controller.accountFromHandler.codeController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}