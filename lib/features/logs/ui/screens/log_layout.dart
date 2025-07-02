// ignore_for_file: deprecated_member_use

import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../controllers/log_controller.dart';

class LogLayout extends StatefulWidget {
  const LogLayout({super.key});

  @override
  State<LogLayout> createState() => _LogLayoutState();
}

class _LogLayoutState extends State<LogLayout> {
  @override
  void initState() {
    final controller = read<LogController>();
    controller.logDateRange.value = controller.defaultDateRange;
    controller.loadLogs(context);
    super.initState();
  }

  void _showDateRangeDialog(BuildContext context, LogController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backGroundColor,
        buttonPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          height: 500,
          width: 450,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SfDateRangePicker(
              showActionButtons: true,
              backgroundColor: AppColors.backGroundColor,
              initialSelectedRange: controller.logDateRange.value,
              onSelectionChanged: controller.onDateRangeSelectionChanged,
              onSubmit: (value) {
                controller.onDateRangeSubmit(context);
                Navigator.pop(context);
              },
              onCancel: () {
                controller.logDateRange.value = controller.defaultDateRange;
                controller.applyFilters();
                Navigator.pop(context);
              },
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = read<LogController>();

    return Scaffold(
      appBar: AppBar(title: const Text('سجل الأحداث')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                /// 📆 Date Range Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDateRangeDialog(context, controller),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Obx(() {
                              final range = controller.logDateRange.value;
                              if (range == null || range.startDate == null || range.endDate == null) {
                                return const Text("التاريخ", style: TextStyle(color: Colors.black54));
                              }
                              final from = controller.formatShortDate(range.startDate!);
                              final to = controller.formatShortDate(range.endDate!);
                              return Text("$to → $from", style: const TextStyle(fontSize: 14, color: Colors.black));
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// 🔍 Search
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث بأسم المستخدم أو الملاحظة...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) => controller.applyFilters(),
                  ),
                ),

                const SizedBox(width: 10),

                /// ⛏️ Event Type Filter
                Expanded(
                  child: Obx(() {
                    return Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedEventType.value,
                          hint: const Text('النوع'),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (value) {
                            controller.selectedEventType.value = value;
                            controller.applyFilters();
                          },
                          items: [
                            DropdownMenuItem(
                              value: controller.allLabel,
                              child: Text(controller.allLabel),
                            ),
                            ...LogEventType.values.map(
                              (e) => DropdownMenuItem(
                                value: e.label,
                                child: Text(e.label),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          /// 🧾 Logs List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.blue));
              }

              if (controller.filteredLogs.isEmpty) {
                return const Center(child: Text('لا يوجد سجلات', style: TextStyle(fontSize: 18)));
              }

              return CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final log = controller.filteredLogs[index];
                        final color = controller.getEventColor(log.eventType);
                        final icon = controller.getEventIcon(log.eventType);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: InkWell(
                            onTap: () => controller.openLogModelOrigin(log, context),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color.withOpacity(0.1),
                                      foregroundColor: color,
                                      radius: 24,
                                      child: Icon(icon),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            log.note,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text("${log.userName} • ${log.sourceType} • #${log.sourceNumber}"),
                                          const SizedBox(height: 4),
                                          Text(
                                            controller.formatDate(log.date),
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: controller.filteredLogs.length,
                    ),
                  )
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}