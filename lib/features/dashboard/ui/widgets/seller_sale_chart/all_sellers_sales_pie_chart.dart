
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../controller/seller_dashboard_controller.dart';

class AllSellersSalesPieChart extends StatelessWidget {
  final SellerDashboardController controller;

  const AllSellersSalesPieChart({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return controller.sellerBillsRequest.value == RequestState.loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              direction: ShimmerDirection.btt,
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 500.h,
                width: 1.1.sw,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )
          : Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              height: 500.h,
              width: 1.1.sw,
              child: PieChart(
                PieChartData(
                  sections: controller.getSellerPieChartSections(),
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 110,
                  sectionsSpace: 0,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      if (!event.isInterestedForInteractions || pieTouchResponse == null) return;
                      final touchedSection = pieTouchResponse.touchedSection;
                      if (event is FlPanDownEvent) {
                        if (touchedSection?.touchedSectionIndex == null|| touchedSection?.touchedSectionIndex == -1) return;
                        controller.lunchSellerScree(context, touchedSection!.touchedSectionIndex);
                      }
                      if (touchedSection == null) return;
                    },
                  ),
                ),
              ),
            );
    });
  }
}