import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/user_time/ui/widgets/user_details_widgets/all_holidays_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../users_management/controllers/user_details_controller.dart';
import '../widgets/user_details_widgets/time_widget.dart';
import '../widgets/user_time_details_widgets/user_daily_time_widget.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = read<UserDetailsController>().selectedUserModel!;
    return Scaffold(
      appBar: AppBar(
        title: Text(userModel.userName!),
        centerTitle: true,
      ),
      body: GetBuilder<UserDetailsController>(builder: (userDetailsController) {
        return ListView(
          children: [
            TimeWidget(
              userDetailsController: userDetailsController,
            ),
            AllHolidaysWidget(
              userDetailsController: userDetailsController,
            ),
            UserDailyTimeWidget(
              userModel: userModel,
            ),
          ],
        );
      }),
    );
  }
}
