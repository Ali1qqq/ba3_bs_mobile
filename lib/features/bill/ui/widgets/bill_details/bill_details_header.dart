import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/widgets/store_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../accounts/controllers/accounts_controller.dart';
import '../../../../accounts/data/models/account_model.dart';
import '../../../../floating_window/services/overlay_service.dart';
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
                label: AppStrings.billType.tr,
                child: Obx(() {
                  return OverlayService.showDropdown<InvPayType>(
                    value: billDetailsController.selectedPayType.value,
                    items: InvPayType.values,
                    itemLabelBuilder: (type) => type.label.tr,
                    onChanged: (selectedType) {
                      if (billModel.billTypeModel.billPatternType?.hasCashesAccount ?? true) {
                        billDetailsController.onPayTypeChanged(selectedType);
                      }
                    },
                    textStyle: const TextStyle(fontSize: 14),
                    height: AppConstants.constHeightTextField,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onCloseCallback: () {
                      log('InvPayType Dropdown Overly Closed.');
                    },
                  );
                }),
              ),
              secondItem: StoreDropdown(storeSelectionHandler: billDetailsController),
            ),
            const VerticalSpace(8),
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: AppStrings.billDate.tr,
                child: Obx(() {
                  return DatePicker(
                    initDate: billDetailsController.billDate.value.dayMonthYear,
                    onDateSelected: (date) {
                      billDetailsController.setBillDate = date;
                    },
                  );
                }),
              ),
              secondItem: SearchableAccountField(
                label: AppStrings.customerAccount.tr,
                textEditingController: billDetailsController.customerAccountController,
                validator: (value) => billDetailsController.validator(value, AppStrings.customerAccount.tr),
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
                label: AppStrings.seller.tr,
                readOnly: true,
                textEditingController: billDetailsController.sellerAccountController,
                onSubmitted: (text) {},
              ),
              secondItem: TextAndExpandedChildField(
                label: AppStrings.illustration.tr,
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