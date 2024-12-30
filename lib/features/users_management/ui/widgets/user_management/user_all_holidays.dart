import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/users_management/ui/widgets/user_management/holiday_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../controllers/user_management_controller.dart';

class UserAllHolidays extends StatelessWidget {
  const UserAllHolidays({super.key, required this.controller});

  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
        titleWidget: Center(
          child: Text(
            "عطل المستخدم",
            style: AppTextStyles.headLineStyle2,
          ),
        ),
        bodyWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 1.sw,
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => HolidayItemWidget(
                  holiday: controller.holidays.elementAt(index),
                  onDelete: () => controller.deleteHoliday(element: controller.holidays.elementAt(index)),
                ),
                separatorBuilder: (context, index) => HorizontalSpace(),
                itemCount: controller.holidaysLength,
              ),
            ),
            SizedBox(
              width: 80,
              // alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                    controller.addHoliday();
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
