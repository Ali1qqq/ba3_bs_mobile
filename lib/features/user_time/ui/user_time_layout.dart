import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/features/user_time/controller/user_time_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserTimeLayout extends StatelessWidget {
  const UserTimeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserTimeController>(builder: (userTimeController) {
      return Column(
        spacing: 50,
        children: [
          Obx(() {
            return AppButton(
              title: "دخول",
              onPressed: () => userTimeController.saveLogInTime(),
              isLoading: userTimeController.logInState.value == RequestState.loading,
            );
          }),
          Obx(() {
            return AppButton(
              title: "خروج",
              onPressed: () => userTimeController.saveLogOutTime(),
              isLoading: userTimeController.logOutState.value == RequestState.loading,
            );
          }),
        ],
      );
    });
  }
}
