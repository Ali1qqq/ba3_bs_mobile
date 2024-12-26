import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/features/user_time/controller/user_time_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserTimeLayout extends StatelessWidget {
  const UserTimeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserTimeController>(builder: (logic) {
      return Column(
        children: [

          AppButton(title: "دخول", onPressed:() => logic.addUserTime(TimeType.logIn), iconData: Icons.login),
          AppButton(title: "خروج", onPressed:() => logic.addUserTime(TimeType.logout), iconData: Icons.logout)
        ],
      );
    });
  }
}
