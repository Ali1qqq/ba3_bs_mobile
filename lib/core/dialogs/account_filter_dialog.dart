import 'package:ba3_bs_mobile/features/accounts/controllers/account_statement_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../styling/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/option_text_widget.dart';

Dialog showAccountFilterDialog(BuildContext context) {
  return Dialog(
    backgroundColor: AppColors.backGroundColor,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GetBuilder<AccountStatementController>(builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text('خيارت العرض'),
              const SizedBox(height: 15),
              OptionTextWidget(
                  title: 'اسم الحساب :  ',
                  controller: controller.accountNameController,
                  onSubmitted: (text) {
                    controller.onAccountNameSubmitted(text, context);
                  }),
              OptionTextWidget(
                title: 'من تاريخ :  ',
                controller: controller.startDateController,
                onSubmitted: controller.onStartDateSubmitted,
              ),
              OptionTextWidget(
                title: 'الى تاريخ :  ',
                controller: controller.endDateController,
                onSubmitted: controller.onEndDateSubmitted,
              ),
              AppButton(
                title: 'موافق',
                iconData: Icons.check,
                onPressed: () {
                  controller
                    ..fetchAccountEntryBondItems()
                    ..navigateToAccountStatementScreen();
                },
              ),
            ],
          );
        }),
      ),
    ),
  );
}