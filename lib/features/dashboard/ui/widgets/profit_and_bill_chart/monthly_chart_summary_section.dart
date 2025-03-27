import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../controller/bill_profit_dashboard_controller.dart';
import '../sheared/chart_box_widget.dart';

class MonthlyChartSummarySection extends StatelessWidget {
  final BillProfitDashboardController controller;

  const MonthlyChartSummarySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
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
                onTap: controller.changeTotalVisibility,
                color: AppColors.totalSaleColor,
                text: AppStrings.totalSales.tr,
                total: controller.totalMonthSales.toStringAsFixed(2),
              ),
              ChartItem(
                onTap:controller.changeProfitVisibility ,
                color: AppColors.feesSaleColor,
                text: AppStrings.totalFees.tr,
                total: controller.totalMonthFees.toStringAsFixed(2),
              ),
            ],
          ),

        ],
      ),
    );
  }
}