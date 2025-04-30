import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../controller/bill_profit_dashboard_controller.dart';

class BillProfitChart extends StatelessWidget {
  final BillProfitDashboardController billProfitDashboardController;

  const BillProfitChart({super.key, required this.billProfitDashboardController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return billProfitDashboardController.profitsBillsRequest.value == RequestState.loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              direction: ShimmerDirection.btt,
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 600.h,
                width: 2.sw,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )
          : SizedBox(
              height: 600,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: 2.5.sw, // twice the screen-width
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        minX: billProfitDashboardController.minX,
                        maxX: billProfitDashboardController.maxX,
                        maxY: billProfitDashboardController.maxY,
                        gridData: FlGridData(show: true),
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                            if (event is FlLongPressStart) {
                              final idx = response?.lineBarSpots?.first.spotIndex;
                              if (idx != null) {
                                billProfitDashboardController.lunchBillScreen(
                                  index: idx,
                                  context: context,
                                );
                              }
                            }
                          },
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) => spots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(2)} ${AppStrings.aed.tr}',
                                TextStyle(
                                  color: spot.barIndex == 0 ? spot.bar.color : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(),
                          rightTitles: AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 50),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: Duration.millisecondsPerDay.toDouble(),
                              getTitlesWidget: (v, meta) => Text(
                                DateFormat('MMM dd').format(
                                  DateTime.fromMillisecondsSinceEpoch(v.toInt(), isUtc: true),
                                ),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: billProfitDashboardController.profitSpots,
                            isCurved: true,
                            show: billProfitDashboardController.isProfitVisible.value,
                            color: AppColors.feesSaleColor,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.feesSaleColor.withOpacity(0.9),
                            ),
                            dotData: FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: billProfitDashboardController.totalSellsSpots,
                            isCurved: true,
                            color: AppColors.totalSaleColor,
                            barWidth: 3,
                            show: billProfitDashboardController.isTotalSalesVisible.value,
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.totalSaleColor.withOpacity(0.3),
                            ),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
    });
  }
}