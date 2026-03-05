import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/user_time/controller/leave_requests_controller.dart';
import 'package:ba3_bs_mobile/features/user_time/data/models/leave_requests_model.dart';
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
                statusText = 'مقبولة';
                break;
              case LeaveStatus.rejected:
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                statusText = 'مرفوضة';
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = Icons.pending;
                statusText = 'قيد الانتظار';
            }

            // تحديد أيقونة نوع الإجازة
            IconData typeIcon;
            String typeText;

            switch (leave.leaveType) {
              case LeaveType.sick:
                typeIcon = Icons.sick;
                typeText = 'مرضية';
                break;
              case LeaveType.paid:
                typeIcon = Icons.attach_money;
                typeText = 'مدفوعة';
                break;
              case LeaveType.unpaid:
                typeIcon = Icons.money_off;
                typeText = 'غير مدفوعة';
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصف العلوي: النوع والحالة
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                size: 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                typeIcon,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                typeText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // تاريخ الإجازة
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'من',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  leave.startDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'إلى',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  leave.endDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // حساب عدد الأيام
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${controller.calculateDays(leave.startDate, leave.endDate)} أيام',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        leave.status == LeaveStatus.pending
                            ? IconButton(
                                onPressed: leave.status == LeaveStatus.pending
                                    ? () => controller.deleteLeave(leave.id)
                                    : null,
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ))
                            : SizedBox()
                      ],
                    ),

                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLeaveDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("طلب إجازة"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // // نافذة تأكيد الإجراءات
  // void _showConfirmationDialog(
  //   BuildContext context,
  //   String title,
  //   String message,
  //   VoidCallback onConfirm,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title),
  //         content: Text(message),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text(
  //               'إلغاء',
  //               style: TextStyle(color: Colors.grey),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               onConfirm();
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor:
  //                   title.contains('قبول') ? Colors.green : Colors.red,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             child: Text(title.contains('قبول') ? 'قبول' : 'رفض'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
          child: Obx(() {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // العنوان
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.beach_access,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'طلب إجازة جديد',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // حقل تاريخ البداية
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.blue,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        controller.startDate.value = dateFormat.format(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'تاريخ البداية',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  controller.startDate.value.isEmpty
                                      ? 'اختر التاريخ'
                                      : controller.startDate.value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        controller.startDate.value.isEmpty
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                    color: controller.startDate.value.isEmpty
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // حقل تاريخ النهاية
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.blue,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        controller.endDate.value = dateFormat.format(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'تاريخ النهاية',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  controller.endDate.value.isEmpty
                                      ? 'اختر التاريخ'
                                      : controller.endDate.value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: controller.endDate.value.isEmpty
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    color: controller.endDate.value.isEmpty
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // نوع الإجازة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<LeaveType>(
                        value: controller.selectedType.value,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: const [
                          DropdownMenuItem(
                            value: LeaveType.sick,
                            child: Row(
                              children: [
                                Icon(Icons.sick,
                                    color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Text('مرضية'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: LeaveType.paid,
                            child: Row(
                              children: [
                                Icon(Icons.attach_money,
                                    color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Text('مدفوعة'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: LeaveType.unpaid,
                            child: Row(
                              children: [
                                Icon(Icons.money_off,
                                    color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('غير مدفوعة'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedType.value = value;
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // أزرار الإجراءات
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          if (controller.addLeaveState.value ==
                              RequestState.loading) {
                            return const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          return ElevatedButton(
                            onPressed: () async {
                              await controller.addLeave();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('إرسال الطلب'),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
