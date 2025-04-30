import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/month_picker.dart';
import '../../../controller/bill_profit_dashboard_controller.dart';

class ProfitDateFilterHeader extends StatelessWidget {
  final BillProfitDashboardController controller;

  const ProfitDateFilterHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 200,
                child: Obx(() {
                  return MonthYearPicker(
                    initMonthYear: controller.profitMonth.value.dayMonthYear,
                    color: AppColors.grayColor,
                    textColor: Colors.white,
                    onMonthYearSelected: (date) {
                      controller.onProfitMothChange(date);
                    },
                  );
                }),
              ),
            ),
            Row(children: [
              Spacer(),
              GestureDetector(
                onTap: () => controller.lunchBillScreen(context: context),
                child: Text(
                  AppStrings.selleAndProfitStatement.tr,
                  style: AppTextStyles.headLineStyle1,
                ),
              ),
              Spacer(),
              InkWell(
                // tooltip: AppStrings.refresh.tr,
                onTap: controller.initProfitChartData,
                // tooltip: AppStrings.refresh.tr,
                child: Icon(
                  FontAwesomeIcons.arrowsRotate,
                  color: AppColors.lightBlueColor,
                  size: 16,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}