import 'package:ba3_bs_mobile/core/widgets/searchable_account_field.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/cheques_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
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
                  label: 'تاريخ التحرير',
                  child: Obx(() {
                    return DatePicker(
                      initDate: chequesDetailsController.chequesDate.value,
                      onDateSelected: chequesDetailsController.setChequesDate,
                    );
                  }),
                ),
                secondItem: TextAndExpandedChildField(
                  label: "تاريخ الاستحقاق",
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
                  label: 'رقم الشيك',
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: chequesDetailsController.chequesNumController,
                    suffixIcon: const SizedBox.shrink(),
                    validator: (value) => chequesDetailsController.validator(value, 'رقم الشيك'),
                  ),
                ),
                secondItem: TextAndExpandedChildField(
                  label: "قيمة الشيك",
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: chequesDetailsController.chequesAmountController,
                    suffixIcon: const SizedBox.shrink(),
                    validator: (value) => chequesDetailsController.validator(value, 'قيمة الشيك'),
                  ),
                )),
            const VerticalSpace(),
            FormFieldRow(
                firstItem: SearchableAccountField(
                  label: 'الحساب',
                  textEditingController: chequesDetailsController.chequesToAccountController,
                  validator: (value) => chequesDetailsController.validator(value, 'الحساب المدفوع له'),
                  chequesDetailsController: chequesDetailsController,
                ),
                secondItem: SearchableAccountField(
                  label: "دفع إلى",
                  textEditingController: chequesDetailsController.chequesAccPtrController,
                  validator: (value) => chequesDetailsController.validator(value, 'الحساب'),
                  chequesDetailsController: chequesDetailsController,
                  isFirstAccountCheque: true,
                )),
            const VerticalSpace(),
            FormFieldRow(
                firstItem: TextAndExpandedChildField(
                  label: "البيان",
                  child: CustomTextFieldWithoutIcon(
                    keyboardType: TextInputType.multiline,
                    maxLine: 4,
                    textEditingController: chequesDetailsController.chequesNoteController,
                    suffixIcon: const SizedBox.shrink(),
                  ),
                ),
                secondItem: const SizedBox()),
          ],
        ),
      ),
    );
  }
}
