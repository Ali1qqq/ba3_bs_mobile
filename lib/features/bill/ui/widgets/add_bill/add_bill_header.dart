import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../../core/widgets/store_dropdown.dart';
import '../bill_shared/bill_header_field.dart';
import '../bill_shared/form_field_row.dart';

class AddBillHeader extends StatelessWidget {
  const AddBillHeader({super.key, required this.addBillController});

  final AddBillController addBillController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: addBillController.formKey,
        child: Column(
          children: [
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: 'تاريخ الفاتورة',
                child: DatePicker(
                  initDate: addBillController.billDate,
                  onDateSelected: addBillController.setBillDate,
                ),
              ),
              secondItem: StoreDropdown(
                storeSelectionHandler: addBillController,
              ),
            ),
            const VerticalSpace(),
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: 'رقم الجوال',
                child: CustomTextFieldWithoutIcon(
                  textEditingController: addBillController.mobileNumberController,
                  suffixIcon: const SizedBox.shrink(),
                ),
              ),
              secondItem: SearchableAccountField(
                label: 'حساب العميل',
                textEditingController: addBillController.customerAccountController,
                validator: (value) => addBillController.validator(value, 'حساب العميل'),
                isCustomerAccount: true,
                billController: addBillController,
                fromAddBill: true,
              ),
            ),
            const VerticalSpace(),
            FormFieldRow(
              firstItem: SearchableAccountField(
                label: 'البائع',
                textEditingController: addBillController.sellerAccountController,
                validator: (value) => addBillController.validator(value, 'البائع'),
                onSubmitted: (text) {
                  read<SellerController>().openSellerSelectionDialog(
                    query: text,
                    textEditingController: addBillController.sellerAccountController,
                    context: context,
                  );
                },
              ),
              secondItem: TextAndExpandedChildField(
                label: 'البيان',
                child: CustomTextFieldWithoutIcon(
                  textEditingController: addBillController.noteController,
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
