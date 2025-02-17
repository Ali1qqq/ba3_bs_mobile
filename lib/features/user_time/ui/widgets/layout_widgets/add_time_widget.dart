import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/organized_widget.dart';
import '../../../../profile/controller/user_time_controller.dart';

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
          AppStrings.work.tr,
          style: AppTextStyles.headLineStyle2,
        )),
        bodyWidget: Column(
          children: [
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    title: AppStrings.checkIn.tr,
                    onPressed: () => userTimeController.checkLogInAndSave(),
                    isLoading: userTimeController.logInState.value == RequestState.loading,
                  ),
                  SizedBox(
                    width: 125.w,
                    child: Text(
                      userTimeController.lastEnterTime.value.tr,
                      style: AppTextStyles.headLineStyle3,
                    ),
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
                    title: AppStrings.checkOut.tr,
                    onPressed: () => userTimeController.checkLogOutAndSave(),
                    isLoading: userTimeController.logOutState.value == RequestState.loading,
                  ),
                  SizedBox(
                    width: 125.w,
                    child: Text(
                      userTimeController.lastOutTime.value.tr,
                      style: AppTextStyles.headLineStyle3,
                    ),
                  )
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}