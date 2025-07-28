import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/profile/ui/widgets/profile_info_row_widget.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../user_time/controller/user_time_controller.dart';
import '../../../user_time/ui/widgets/layout_widgets/add_time_widget.dart';
import '../../../user_time/ui/widgets/layout_widgets/holidays_widget.dart';
import '../../../user_time/ui/widgets/layout_widgets/jetour_days_widget.dart';
import '../../../user_time/ui/widgets/layout_widgets/user_daily_time_widget.dart';
import '../widgets/profile_footer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: GetBuilder<UserManagementController>(builder: (controller) {
            return Column(
              spacing: 10,
              children: [
                ProfileInfoRowWidget(
                  label: AppStrings.userName.tr,
                  value: controller.loggedInUserModel!.userName.toString(),
                ),
                ProfileInfoRowWidget(
                  label: AppStrings.password.tr,
                  value: controller.isPasswordVisible.value ? controller.loggedInUserModel!.userPassword.toString() : "●" * 6,
                  icon: IconButton(
                      onPressed: () {
                        controller.updatePasswordVisibility();
                      },
                      icon: Icon(controller.isPasswordVisible.value ? FontAwesomeIcons.eyeLowVision : FontAwesomeIcons.eye)),
                ),
                ProfileInfoRowWidget(
                  label: AppStrings.userSalary.tr,
                  value: controller.loggedInUserModel!.userSalary ?? '0.0',
                ),
                ProfileInfoRowWidget(
                  label: AppStrings.delayedEntry.tr,
                  value: read<UserTimeController>().getTotalLoginDelayTime,
                ),
                ProfileInfoRowWidget(
                  label: AppStrings.leaveEarly.tr,
                  value: read<UserTimeController>().getTotalOutEarlierTime,
                ),
                AddTimeWidget(
                  userTimeController: read<UserTimeController>(),
                ),
                HolidaysWidget(
                  userTimeController: read<UserTimeController>(),
                ),
                JetourDaysWidget(
                  userTimeController: read<UserTimeController>(),
                ),
                UserDailyTimeWidget(
                  userModel: read<UserTimeController>().getUserById,
                ),
                const ProfileFooter(),
              ],
            );
          }),
        ),
      ),
    );
  }
}