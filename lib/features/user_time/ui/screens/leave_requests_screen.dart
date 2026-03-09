import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/user_time/controller/leave_requests_controller.dart';
import 'package:ba3_bs_mobile/features/user_time/data/models/leave_requests_model.dart';
import 'package:ba3_bs_mobile/features/user_time/ui/widgets/content_add_leave_dialog_widget.dart';
import 'package:ba3_bs_mobile/features/user_time/ui/widgets/leave_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeavePage extends StatelessWidget {
  LeavePage({super.key});

  final LeaveController controller = Get.find<LeaveController>();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.getLeavesState.value == RequestState.loading ||
            controller.deleteLeaveState.value == RequestState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.leaves.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.beach_access,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "لا توجد طلبات إجازة",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "اضغط على زر + لإضافة طلب جديد",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.leaves.length,
          itemBuilder: (context, index) {
            final leave = controller.leaves[index];

            // تحديد لون الحالة
            Color statusColor;
            IconData statusIcon;
            String statusText;

            switch (leave.status) {
              case LeaveStatus.approved:
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                statusText = AppStrings.approved.tr;
                break;
              case LeaveStatus.rejected:
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                statusText = AppStrings.rejected.tr;
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = Icons.pending;
                statusText = AppStrings.pending.tr;
            }

            // تحديد أيقونة نوع الإجازة
            IconData typeIcon;
            String typeText;

            switch (leave.leaveType) {
              case LeaveType.sick:
                typeIcon = Icons.sick;
                typeText = AppStrings.sickLeave.tr;
                break;
              case LeaveType.paid:
                typeIcon = Icons.attach_money;
                typeText = AppStrings.paidLeave.tr;
                break;
              case LeaveType.unpaid:
                typeIcon = Icons.money_off;
                typeText = AppStrings.unpaidLeave.tr;
                break;
            }

            return LeaveCardWidget(
                statusColor: statusColor,
                statusIcon: statusIcon,
                statusText: statusText,
                typeIcon: typeIcon,
                typeText: typeText,
                leave: leave,
                controller: controller);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLeaveDialog(context),
        icon: const Icon(Icons.add),
        label: Text(AppStrings.leaveRequest.tr),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // نافذة إضافة طلب إجازة جديد
  void _showAddLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ContentAddLeaveDialog(
              controller: controller, dateFormat: dateFormat),
        );
      },
    );
  }
}
