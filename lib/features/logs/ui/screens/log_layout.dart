import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../controllers/log_controller.dart';

class LogLayout extends StatefulWidget {
  const LogLayout({super.key});

  @override
  State<LogLayout> createState() => _LogLayoutState();
}

class _LogLayoutState extends State<LogLayout> {
  @override
  void initState() {
    read<LogController>().loadLogs();
    super.initState();
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
                Expanded(
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
                Obx(() {
                  return DropdownButton<String>(
                    value: controller.selectedEventType.value,
                    hint: const Text('النوع'),
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
                  );
                })
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.blue));
              }

              if (controller.filteredLogs.isEmpty) {
                return const Center(
                  child: Text('لا يوجد سجلات', style: TextStyle(fontSize: 18)),
                );
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