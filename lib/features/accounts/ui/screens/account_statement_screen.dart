import 'package:ba3_bs_mobile/features/accounts/controllers/account_statement_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../widgets/account_statement_detail.dart';

class AccountStatementScreen extends StatelessWidget {
  const AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountStatementController>(
      builder: (controller) {
        return PlutoGridWithAppBar(
          title: controller.screenTitle,
          onLoaded: (e) {},
          onSelected: (event) {
            final originId = event.row?.cells['originId']?.value;
            controller.launchBondEntryBondScreen(context: context, originId: originId);
          },
          isLoading: controller.isLoading,
          tableSourceModels: controller.filteredEntryBondItems,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Display Debit
                AccountStatementDetail(
                  label: 'مدين : ',
                  value: AppUIUtils.formatDecimalNumberWithCommas(controller.debitValue),
                  valueColor: Colors.blue.shade700,
                ),
                // Display Credit
                AccountStatementDetail(
                  label: 'دائن : ',
                  value: AppUIUtils.formatDecimalNumberWithCommas(controller.creditValue),
                  valueColor: Colors.blue.shade700,
                ),
                // Display Total
                AccountStatementDetail(
                  label: 'المجموع : ',
                  value: AppUIUtils.formatDecimalNumberWithCommas(controller.totalValue),
                  valueColor: Colors.blue.shade700,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
