import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../controller/seller_dashboard_controller.dart';
import '../sheared/chart_box_widget.dart';

class SellerChartSummarySection extends StatelessWidget {
  final SellerDashboardController controller;

  const SellerChartSummarySection({super.key, required this.controller});

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
                color: AppColors.totalSaleColor,
                text: AppStrings.totalSales.tr,
                total: controller.totalSellerSales.toStringAsFixed(2),
              ),
              ChartItem(
                color: AppColors.mobileSaleColor,
                onTap:controller.changeSellerTotalMobileTarget,
                text: AppStrings.totalMobileTarget.tr,
                total: controller.totalSellerSalesMobile.toStringAsFixed(2),
              ),
            ],
          ),
          ChartColumn(
            items: [
              ChartItem(
                onTap:controller.changeSellerAccessoryTarget,

                color: AppColors.accessorySaleColor,
                text: AppStrings.totalAccessoriesTarget.tr,
                total: controller.totalSellerSalesAccessory.toStringAsFixed(2),
              ),
              ChartItem(
                onTap:controller.changeSellerTotalFees,

                color: AppColors.feesSaleColor,
                text: AppStrings.totalFees.tr,
                total: controller.totalSellerFees.toStringAsFixed(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}