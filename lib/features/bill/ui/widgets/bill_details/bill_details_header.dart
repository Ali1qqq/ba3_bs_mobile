import 'package:ba3_bs_mobile/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/widgets/store_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../accounts/controllers/accounts_controller.dart';
import '../../../../accounts/data/models/account_model.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../data/models/bill_model.dart';
import '../bill_shared/bill_header_field.dart';
import '../bill_shared/form_field_row.dart';

class BillDetailsHeader extends StatelessWidget {
  const BillDetailsHeader({
    super.key,
    required this.billDetailsController,
    required this.billModel,
  });

  final BillDetailsController billDetailsController;
  final BillModel billModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: billDetailsController.formKey,
        child: Column(
          children: [
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: 'تاريخ الفاتورة',
                child: Obx(() {
                  return DatePicker(
                    initDate: billDetailsController.billDate.value.dayMonthYear,
                    onDateSelected: (date) {
                      billDetailsController.setBillDate = date;
                    },
                  );
                }),
              ),
              secondItem: StoreDropdown(storeSelectionHandler: billDetailsController),
            ),
            const VerticalSpace(8),
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: 'رقم الجوال',
                child: CustomTextFieldWithoutIcon(
                  textEditingController: billDetailsController.mobileNumberController,
                  // suffixIcon: const SizedBox.shrink(),
                ),
              ),
              secondItem: SearchableAccountField(
                label: 'حساب العميل',
                textEditingController: billDetailsController.customerAccountController,
                validator: (value) => billDetailsController.validator(value, 'حساب العميل'),
                onSubmitted: (text) async {
                  AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                    query: text,
                    context: context,
                  );
                  if (accountModel != null) {
                    billDetailsController.updateCustomerAccount(accountModel);
                  }
                },
              ),
            ),
            const VerticalSpace(8),
            FormFieldRow(
              firstItem: SearchableAccountField(
                label: 'البائع',
                readOnly: true,
                textEditingController: billDetailsController.sellerAccountController,
                validator: (value) => billDetailsController.validator(value, 'البائع'),
                onSubmitted: (text) {
                  // read<SellerController>().openSellerSelectionDialog(
                  //   query: text,
                  //   textEditingController: billDetailsController.sellerAccountController,
                  //   context: context,
                  // );
                },
              ),
              secondItem: TextAndExpandedChildField(
                label: 'البيان',
                child: CustomTextFieldWithoutIcon(
                  textEditingController: billDetailsController.noteController,
                  suffixIcon: const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
