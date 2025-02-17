import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
    return OrganizedWidget(
      titleWidget: Center(
          child: Text(
        AppStrings.work.tr,
        style: AppTextStyles.headLineStyle2,
      )),
      bodyWidget: Column(
        children: [
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppButton(
                  title: AppStrings.checkIn.tr,
                  width: 40.w,
                  height: 20,
                  onPressed: () => userTimeController.checkLogInAndSave(),
                  isLoading: userTimeController.logInState.value == RequestState.loading,
                ),
                Spacer(),
                SizedBox(
                  width: 45.w,
                  child: Text(
                    userTimeController.lastEnterTime.value,
                    style: AppTextStyles.headLineStyle3,
                  ),
                ),
              ],
            );
          }),
          Divider(),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppButton(
                  title: AppStrings.checkOut.tr,
                  width: 40.w,
                  height: 20,
                  onPressed: () => userTimeController.checkLogOutAndSave(),
                  isLoading: userTimeController.logOutState.value == RequestState.loading,
                ),
                Spacer(),
                SizedBox(
                  width: 45.w,
                  child: Text(
                    userTimeController.lastOutTime.value,
                    style: AppTextStyles.headLineStyle3,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}