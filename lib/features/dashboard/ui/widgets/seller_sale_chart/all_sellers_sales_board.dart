import 'package:ba3_bs_mobile/features/dashboard/ui/widgets/seller_sale_chart/all_sellers_sales_bar_chart.dart';
import 'package:ba3_bs_mobile/features/dashboard/ui/widgets/seller_sale_chart/seller_chart_summary_section.dart';
import 'package:flutter/material.dart';

import '../../../controller/seller_dashboard_controller.dart';
import 'all_sellers_sales_pie_chart.dart';
import 'seller_date_filter_header.dart';

class AllSellersSalesBoard extends StatelessWidget {
  final SellerDashboardController controller;

  const AllSellersSalesBoard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SellerDateFilterHeader(controller: controller),
        AnimatedCrossFade(
            firstChild: AllSellersSalesBarChart(controller: controller),
            secondChild: AllSellersSalesPieChart(controller: controller),
            crossFadeState: controller.crossSellerFadeState,
            duration: Durations.extralong4),
        SellerChartSummarySection(controller: controller),
      ],
    );
  }
}