import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/user_time_controller.dart';
import '../widgets/user_time_details_widgets/add_time_widget.dart';
import '../widgets/user_time_details_widgets/holidays_widget.dart';
import '../widgets/user_time_details_widgets/user_daily_time_widget.dart';

class UserTimeDetails extends StatelessWidget {
  const UserTimeDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<UserTimeController>(builder: (userTimeController) {

        return ListView(
          physics: ClampingScrollPhysics(),
          children: [
            AddTimeWidget(
              userTimeController: userTimeController,
            ),
            HolidaysWidget(
              userTimeController: userTimeController,
            ),
            UserDailyTimeWidget(
              userModel: userTimeController.getUserById()!,
            ),
          ],
        );
      }),
    );
  }
}
