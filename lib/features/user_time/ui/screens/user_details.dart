import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/features/user_time/ui/widgets/user_details_widgets/all_holidays_widget.dart';
import 'package:ba3_bs_mobile/features/user_time/ui/widgets/user_details_widgets/user_total_delay_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_drop_down.dart';
import '../../../profile/ui/widgets/user_time_details_widgets/user_daily_time_widget.dart';
import '../../../users_management/controllers/user_details_controller.dart';
import '../widgets/user_details_widgets/time_widget.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = read<UserDetailsController>().selectedUserModel!;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${AppStrings.userName.tr}: ',
              style: AppTextStyles.headLineStyle1,
            ),
            Text(
              userModel.userName!,
              style: AppTextStyles.headLineStyle1,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: GetBuilder<UserDetailsController>(builder: (userDetailsController) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                CustomDropDown(
                  value: userDetailsController.userFormHandler.userListSelectedMonth.toString().tr,
                  listValue: (AppConstants.months.keys.toList()),
                  label: "اختر الشهر".tr,
                  onChange: (value) {
                    if (value != null) {
                      userDetailsController.userFormHandler.updateSelectedMonth(value);
                    }
                  },
                  isFullBorder: true,
                ),
                AllHolidaysWidget(
                  userDetailsController: userDetailsController,
                ),
                UserDailyTimeWidget(
                  userModel: userModel,
                ),
                TimeWidget(
                  userDetailsController: userDetailsController,
                ),
                if (userDetailsController.userFormHandler.userTimeModelWithTotalDelayAndEarlierAtMonth != null)
                  UserTotalDelay(
                    userDetailsController: userDetailsController,
                  )
              ],
            ),
          ),
        );
      }),
    );
  }
}