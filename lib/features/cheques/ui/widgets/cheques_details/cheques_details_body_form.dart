import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/searchable_account_field.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/cheques_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../accounts/controllers/accounts_controller.dart';
import '../../../../accounts/data/models/account_model.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../../bill/ui/widgets/bill_shared/form_field_row.dart';

class AddChequeForm extends StatelessWidget {
  const AddChequeForm({super.key, required this.chequesDetailsController});

  final ChequesDetailsController chequesDetailsController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: chequesDetailsController.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FormFieldRow(
                firstItem: TextAndExpandedChildField(
                  label: AppStrings.editingDate.tr,
                  child: Obx(() {
                    return DatePicker(
                      initDate: chequesDetailsController.chequesDate.value,
                      onDateSelected: chequesDetailsController.setChequesDate,
                    );
                  }),
                ),
                secondItem: TextAndExpandedChildField(
                  label: AppStrings.duesDate.tr,
                  child: Obx(() {
                    return DatePicker(
                      initDate: chequesDetailsController.chequesDueDate.value,
                      onDateSelected: chequesDetailsController.setChequesDueDate,
                    );
                  }),
                )),
            const VerticalSpace(),
            FormFieldRow(
                firstItem: TextAndExpandedChildField(
                  label: AppStrings.chequesNumber.tr,
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: chequesDetailsController.chequesNumController,
                    suffixIcon: const SizedBox.shrink(),
                    validator: (value) => chequesDetailsController.validator(value, 'رقم الشيك'),
                  ),
                ),
                secondItem: TextAndExpandedChildField(
                  label: AppStrings.chequesAmount.tr,
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: chequesDetailsController.chequesAmountController,
                    suffixIcon: const SizedBox.shrink(),
                    validator: (value) => chequesDetailsController.validator(value, 'قيمة الشيك'),
                  ),
                )),
            const VerticalSpace(),
            FormFieldRow(
                firstItem: SearchableAccountField(
                  label: AppStrings.account.tr,
                  onSubmitted: (text) async {
                    AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                      query: text,
                      context: context,
                    );
                    if (accountModel != null) {
                      chequesDetailsController.setTowAccount(accountModel);
                    }
                  },
                  textEditingController: chequesDetailsController.chequesToAccountController,
                  validator: (value) => chequesDetailsController.validator(value, 'الحساب المدفوع له'),
                ),
                secondItem: SearchableAccountField(
                  label: '${AppStrings.pay.tr} ${AppStrings.to.tr}',
                  textEditingController: chequesDetailsController.chequesAccPtrController,
                  validator: (value) => chequesDetailsController.validator(value, 'الحساب'),
                  onSubmitted: (text) async {
                    AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                      query: text,
                      context: context,
                    );
                    if (accountModel != null) {
                      chequesDetailsController.setFirstAccount(accountModel);
                    }
                  },
                )),
            const VerticalSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppStrings.illustration.tr),
                HorizontalSpace(70),
                Expanded(
                  child: CustomTextFieldWithoutIcon(
                    height: 60,
                    keyboardType: TextInputType.multiline,
                    maxLine: 4,
                    textEditingController: chequesDetailsController.chequesNoteController,
                    suffixIcon: const SizedBox.shrink(),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}