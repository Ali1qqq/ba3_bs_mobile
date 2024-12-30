import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/organized_widget.dart';
import '../../../controller/user_time_controller.dart';

class AddTimeWidget extends StatelessWidget {
  const AddTimeWidget({
    super.key,
    required this.userTimeController,
  });

  final UserTimeController userTimeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
        titleWidget: Center(
            child: Text(
          "تسجيل الدوام",
          style: AppTextStyles.headLineStyle2,
        )),
        bodyWidget: Column(
          children: [
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    title: "دخول",
                    onPressed: () => userTimeController.checkLogInAndSave(),
                    isLoading: userTimeController.logInState.value == RequestState.loading,
                  ),
                  Text(
                    userTimeController.lastEnterTime.value,
                    style: AppTextStyles.headLineStyle3,
                  ),
                ],
              );
            }),
            Divider(),
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    title: "خروج",
                    onPressed: () => userTimeController.checkLogOutAndSave(),
                    isLoading: userTimeController.logOutState.value == RequestState.loading,
                  ),
                  Text(
                    userTimeController.lastOutTime.value,
                    style: AppTextStyles.headLineStyle3,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
