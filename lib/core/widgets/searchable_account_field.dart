import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/cheques_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/bond/controllers/bonds/bond_details_controller.dart';
import '../constants/app_constants.dart';
import '../helper/extensions/getx_controller_extensions.dart';
import '../i_controllers/i_bill_controller.dart';
import 'custom_text_field_with_icon.dart';

class SearchableAccountField extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;
  final bool isCustomerAccount; // Add this parameter to indicate customer account field
  final bool fromAddBill; // Add this parameter to indicate customer account field
  final Function(String text)? onSubmitted;
  final FormFieldValidator<String>? validator;
  final double? height;
  final double? width;
  final IBillController? billController;
  final BondDetailsController? bondDetailsController;
  final ChequesDetailsController? chequesDetailsController;
  final bool isFirstAccountCheque;

  const SearchableAccountField({
    super.key,
    required this.label,
    required this.textEditingController,
    this.billController,
    this.onSubmitted,
    this.validator,
    this.isCustomerAccount = false,
    this.fromAddBill = false,
    this.height,
    this.width,
    this.bondDetailsController,
    this.chequesDetailsController,
    this.isFirstAccountCheque = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? Get.width * 0.45,
      height: AppConstants.constHeightTextField,
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: CustomTextFieldWithIcon(
              textEditingController: textEditingController,
              validator: validator,
              onSubmitted: onSubmitted ??
                  (text) {
                    read<AccountsController>().openAccountSelectionDialog(
                      query: text,
                      textEditingController: textEditingController,
                      isCustomerAccount: isCustomerAccount,
                      fromAddBill: fromAddBill,
                      context: context,
                      bondDetailsController: bondDetailsController,
                      billController: billController,
                      chequesDetailsController: chequesDetailsController,
                      isFirstAccountCheque: isFirstAccountCheque,
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }
}
