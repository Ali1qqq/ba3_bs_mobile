import 'package:ba3_bs_mobile/features/user_time/controller/user_time_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/layout_widgets/add_time_widget.dart';
import '../widgets/layout_widgets/holidays_widget.dart';
import '../widgets/layout_widgets/user_daily_time_widget.dart';

class UserTimeLayout extends StatelessWidget {
  const UserTimeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserTimeController>(builder: (userTimeController) {
      return Column(
        children: [
          AddTimeWidget(
            userTimeController: userTimeController,
          ),
          HolidaysWidget(),
          UserDailyTimeWidget(),
        ],
      );
    });
  }
}
