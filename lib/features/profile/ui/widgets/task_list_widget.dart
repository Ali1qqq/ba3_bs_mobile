import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/task_status_extension.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/features/user_task/data/model/user_task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/styling/app_text_style.dart';

class TaskListExpansionTile extends StatelessWidget {
  final List<UserTaskModel> taskList;
  final Function(UserTaskModel) onTap;
  final String title;

  const TaskListExpansionTile({
    super.key,
    required this.taskList,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final generalTaskList = taskList.where((element) => element.taskType == TaskType.generalTask).toList();
    final saleTaskList = taskList.where((element) => element.taskType == TaskType.saleTask).toList();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        // إزالة أي padding إضافي قد يؤدي لظهور حدود
        tilePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
        childrenPadding: EdgeInsets.zero,

        // تعيين الخلفيات لتكون شفافة لتفادي ظهور خطوط غير مرغوبة
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text(
          title,
          style: AppTextStyles.headLineStyle3,
        ),
        trailing: Text(
          taskList.length.toString(),
          style: AppTextStyles.headLineStyle3.copyWith(color: Colors.black),
        ),
        children: [
          for (int i = 0; i < generalTaskList.length; i++) ...[
            ListTile(
              onTap: () => onTap(generalTaskList[i]),
              title: Text(
                generalTaskList[i].title ?? '',
                style: AppTextStyles.headLineStyle3,
                maxLines: 3,
              ),
              // subtitle: Text(
              //   "اخر تاريخ للمهمة ${taskList[i].dueDate?.dayMonthYear ?? ''}",
              //   style: TextStyle(color: Colors.red),
              // ),
              // trailing: Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(taskList[i].taskType?.label ?? ''),
              //     Text(
              //       taskList[i].status?.value ?? '',
              //       style: AppTextStyles.headLineStyle4.copyWith(
              //         color: taskList[i].status != null
              //             ? (taskList[i].status!.isFailed
              //                 ? Colors.red
              //                 : taskList[i].status!.isInProgress
              //                     ? Colors.green
              //                     : AppColors.mobileSaleColor)
              //             : Colors.black,
              //       ),
              //     ),
              //   ],
              // ),
            ),
            Divider(height: 1, thickness: 1)
          ],
          for (int i = 0; i < saleTaskList.length; i++) ...[
            ListTile(
              onTap: () => onTap(saleTaskList[i]),
              title: Text(
                saleTaskList[i].title ?? '',
                style: AppTextStyles.headLineStyle3,
              ),
              subtitle: Text(
                "اخر تاريخ للمهمة ${saleTaskList[i].dueDate?.dayMonthYear ?? ''}",
                style: TextStyle(color: Colors.red),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(saleTaskList[i].taskType?.label ?? ''),
                  Text(
                    saleTaskList[i].status?.value ?? '',
                    style: AppTextStyles.headLineStyle4.copyWith(
                      color: saleTaskList[i].status != null
                          ? (saleTaskList[i].status!.isFailed
                              ? Colors.red
                              : saleTaskList[i].status!.isInProgress
                                  ? Colors.green
                                  : AppColors.mobileSaleColor)
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // إضافة فاصل بين العناصر فقط، دون فاصل في البداية أو النهاية
            if (i < taskList.length - 1) Divider(height: 1, thickness: 1),
          ]
        ],
      ),
    );
  }
}