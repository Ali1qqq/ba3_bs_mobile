import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../controller/cheques_timeline_controller.dart';

class ChequesBarChart extends StatelessWidget {
  final ChequesTimelineController chequesTimelineController;

  const ChequesBarChart({super.key, required this.chequesTimelineController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return chequesTimelineController.chequesChartRequestState.value == RequestState.loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              direction: ShimmerDirection.btt,
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 450.h,
                width: 2.sw,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )
          : SizedBox(
              height: 450.h, // ارتفاع ثابت
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  height: 450.h,
                  width: 2.sw,
                  // عرض مضاعف للشاشة
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        handleBuiltInTouches: true, // ضروري لتلقّي أحداث الـ long-press
                        touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                          if (event is FlLongPressStart) {
                            final x = response?.spot?.spot.x;
                            if (x != null) {
                              chequesTimelineController.lunchChequesScreen(
                                context,
                                x.toInt(),
                              );
                            }
                          }
                        },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.black,
                          tooltipBorder: BorderSide(color: AppColors.backGroundColor),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.toString()} ',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      maxY: chequesTimelineController.sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble() + 1,
                      barGroups: chequesTimelineController.barGroups,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < chequesTimelineController.datesList.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat('MM/dd').format(
                                      DateTime.parse(chequesTimelineController.datesList[idx]),
                                    ),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                    ),
                  ),
                ),
              ),
            );
    });
  }
}