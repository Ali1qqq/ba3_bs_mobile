/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../../../profile/controller/user_time_controller.dart';
import '../widgets/layout_widgets/add_time_widget.dart';
import '../widgets/layout_widgets/holidays_widget.dart';
import '../widgets/layout_widgets/user_daily_time_widget.dart';

class UserTimeLayout extends StatelessWidget {
  const UserTimeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<UserTimeController>(builder: (userTimeController) {
        return RefreshIndicator(
          onRefresh: () => read<UserManagementController>().refreshLoggedInUser(),

          child: Column(
            children: [
              AddTimeWidget(
                userTimeController: userTimeController,
              ),
              HolidaysWidget(
                userTimeController: userTimeController,
              ),
              UserDailyTimeWidget(
                userTimeController: userTimeController,
              ),
            ],
          ),
        );
      }),
    );
  }
}
*/