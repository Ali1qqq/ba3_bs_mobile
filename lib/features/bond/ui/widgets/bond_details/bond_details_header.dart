import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/searchable_account_field.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/bond_details_controller.dart';
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

class BondDetailsHeader extends StatelessWidget {
  const BondDetailsHeader({
    super.key,
    required this.bondDetailsController,
  });

  final BondDetailsController bondDetailsController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: bondDetailsController.formKey,
        child: Column(
          children: [
            FormFieldRow(
                firstItem: TextAndExpandedChildField(
                  label: AppStrings.bondDate.tr,
                  child: Obx(() {
                    return DatePicker(
                      initDate: bondDetailsController.bondDate.value,
                      onDateSelected: bondDetailsController.setBondDate,
                    );
                  }),
                ),
                secondItem: TextAndExpandedChildField(
                  label: AppStrings.illustration.tr,
                  child: CustomTextFieldWithoutIcon(
                    height: 30,
                    textEditingController: bondDetailsController.noteController,
                    // suffixIcon: const SizedBox.shrink(),
                  ),
                )),
            const VerticalSpace(8),
            if (bondDetailsController.isDebitOrCredit == true) ...[
              FormFieldRow(
                  firstItem: SearchableAccountField(
                    validator: (value) {
                      if (bondDetailsController.isDebitOrCredit) {
                        return bondDetailsController.validator(value, 'الحساب');
                      }
                      return null;
                    },
                    label: "${AppStrings.account.tr} : ",
                    onSubmitted: (text) async {
                      AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                        query: text,
                        context: context,
                      );
                      if (accountModel != null) {
                        bondDetailsController.setAccount(accountModel);
                      }
                    },
                    textEditingController: bondDetailsController.accountController,
                  ),
                  secondItem: Container()),
              const VerticalSpace(8),
            ]
          ],
        ),
      ),
    );
  }
}