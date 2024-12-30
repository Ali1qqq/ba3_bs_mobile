import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/users_management/ui/widgets/user_management/working_hour_widget.dart';
import 'package:flutter/material.dart';

import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../controllers/user_management_controller.dart';

class UserAllWorkingHour extends StatelessWidget {
  const UserAllWorkingHour({super.key, required this.controller});

  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
        titleWidget: Center(
          child: Text(
            "دوام المستخدم",
            style: AppTextStyles.headLineStyle2,
          ),
        ),
        bodyWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) => WorkingHoursItem(
                onDelete: () => controller.deleteWorkingHour(key: index),
                onEnterTimeChange: (time) {
                  controller.setEnterTime(index, time);
                },
                onOutTimeChange: (time) {
                  controller.setOutTime(index, time);
                },
                userWorkingHours: controller.workingHours.values.elementAt(index),
              ),
              separatorBuilder: (context, index) => VerticalSpace(),
              itemCount: controller.workingHoursLength,
            ),
            SizedBox(
              width: 80,
              // alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                    controller.addWorkingHour();
                  },
                  icon: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 12,
                        color: AppColors.blueColor,
                      ),
                      HorizontalSpace(),
                      Text(
                        'اضافة',
                        style: AppTextStyles.headLineStyle4.copyWith(fontSize: 12, color: AppColors.blueColor),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
