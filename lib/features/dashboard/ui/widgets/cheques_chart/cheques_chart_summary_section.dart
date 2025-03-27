import 'package:ba3_bs_mobile/features/dashboard/controller/cheques_timeline_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/styling/app_colors.dart';
import '../sheared/chart_box_widget.dart';

class ChequesChartSummarySection extends StatelessWidget {
  final ChequesTimelineController controller;

  const ChequesChartSummarySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ChartColumn(
            items: [
              ChartItem(
                color: Colors.red,
                text: AppStrings.today.tr,
                total: controller.allChequesDuesTodayLength.toString(),
              ),
              ChartItem(
                color: AppColors.blueColor,
                // onTap:controller.changeSellerTotalMobileTarget,
                text: AppStrings.lastTenDays.tr,
                total: controller.allChequesDuesLastTenLength.toString(),
              ),
            ],
          ),
          ChartColumn(
            items: [
              ChartItem(
                // onTap:controller.changeSellerAccessoryTarget,

                color: AppColors.accessorySaleColor,
                text: AppStrings.thisMonth.tr,
                total: controller.allChequesDuesThisMonthLength.toString(),
              ),
              ChartItem(
                // onTap:controller.changeSellerTotalFees,

                color: AppColors.feesSaleColor,
                text: AppStrings.all.tr,
                total: controller.allChequesDuesLength.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}