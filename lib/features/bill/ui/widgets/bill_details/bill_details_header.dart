import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/core/widgets/store_dropdown.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/customer/data/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../accounts/data/models/account_model.dart';
import '../../../../floating_window/services/overlay_service.dart';
import '../../../../sellers/controllers/sellers_controller.dart';
import '../../../../sellers/data/models/seller_model.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Form(
        key: billDetailsController.formKey,
        child: Column(
          children: [
            SearchableAccountField(
              label: AppStrings.account.tr,
              textEditingController: billDetailsController.billAccountController,
              validator: (value) => billDetailsController.validator(value, AppStrings.account.tr),
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  billDetailsController.updateBillAccount(accountModel);
                }
              },
            ),
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
                    height: AppConstants.constHeightDropDown,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onCloseCallback: () {},
                  );
                }),
              ),
              secondItem: StoreDropdown(storeSelectionHandler: billDetailsController),
            ),
            VerticalSpace(),
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
                // validator: (value) => billDetailsController.validator(value, AppStrings.customerAccount.tr),
                onSubmitted: (text) async {
                  CustomerModel? customerModel = await read<AccountsController>().openCustomerSelectionDialog(
                    accountId: billDetailsController.selectedBillAccount?.id!,
                    query: text,
                    context: context,
                  );
                  if (customerModel != null) {
                    billDetailsController.updateCustomerAccount(customerModel, billModel.billTypeModel);
                  }
                },
              ),
            ),
            FormFieldRow(
              firstItem: SearchableAccountField(
                label: AppStrings.seller.tr,
                readOnly: false,
                textEditingController: billDetailsController.sellerAccountController,
                onSubmitted: (text) async {
                  SellerModel? sellerModel = await read<SellersController>().openSellerSelectionDialog(
                    query: text,
                    context: context,
                  );
                  if (sellerModel != null) {
                    billDetailsController.updateSellerAccount(sellerModel);
                  }
                },
              ),
              secondItem: TextAndExpandedChildField(
                label: AppStrings.illustration.tr,
                child: CustomTextFieldWithoutIcon(
                  textEditingController: billDetailsController.noteController,
                  suffixIcon: const SizedBox.shrink(),
                ),
              ),
            ),
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: AppStrings.phoneNumber.tr,
                child: CustomTextFieldWithoutIcon(
                  textEditingController: billDetailsController.customerPhoneController,
                  suffixIcon: const SizedBox.shrink(),
                ),
              ),
              secondItem: TextAndExpandedChildField(
                label: AppStrings.orderNumber.tr,
                child: CustomTextFieldWithoutIcon(
                  textEditingController: billDetailsController.orderNumberController,
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