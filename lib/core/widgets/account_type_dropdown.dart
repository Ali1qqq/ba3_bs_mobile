import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/interfaces/i_account_type_selection_handler.dart';
import 'package:ba3_bs_mobile/features/floating_window/services/overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../constants/app_constants.dart';

class AccountTypeDropdown extends StatelessWidget {
  const AccountTypeDropdown({super.key, required this.accountSelectionHandler, this.width});

  final IAccountTypeSelectionHandler accountSelectionHandler;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return TextAndExpandedChildField(
      label: AppStrings.accountType.tr,
      child: Container(
        width: (Get.width * 0.45) - 100,
        height: AppConstants.constHeightDropDown,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Obx(() {
          return OverlayService.showDropdown<AccountType>(
            value: accountSelectionHandler.selectedAccountType.value,
            items: AccountType.values,
            onChanged: accountSelectionHandler.onSelectedAccountTypeChanged,
            textStyle: const TextStyle(fontSize: 14),
            itemLabelBuilder: (tax) => tax.title,
            height: AppConstants.constHeightTextField,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              borderRadius: BorderRadius.circular(5),
            ),
            onCloseCallback: () {},
          );
        }),
      ),
    );
  }
}