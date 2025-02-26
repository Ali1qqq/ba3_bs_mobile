import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key, required this.user});

  final UserModel user;

  // حساب إجمالي التأخر في تسجيل الدخول
  String calculateTotalLoginDelay(Map<String, UserWorkingHours> workingHours, UserTimeModel timeModel) {
    if (timeModel.logInDateList == null || timeModel.logInDateList?.length != workingHours.entries.length) {
      return AppStrings.currentlyUnavailable;
    }
    int totalMinutes = 0;
    for (int i = 0; i < timeModel.logInDateList!.length; i++) {
      final enterTime = DateFormat("hh:mm a").parse(workingHours.values.elementAt(i).enterTime!);
      final loginTime = timeModel.logInDateList!.elementAt(i);
      final delay = loginTime.difference(DateTime(loginTime.year, loginTime.month, loginTime.day, enterTime.hour, enterTime.minute));
      if (!delay.isNegative) {
        totalMinutes += delay.inMinutes;
      }
    }
    return formatDelay(totalMinutes);
  }

  // حساب إجمالي التأخر في تسجيل الخروج
  String calculateTotalLogoutDelay(Map<String, UserWorkingHours> workingHours, UserTimeModel timeModel) {
    if (timeModel.logOutDateList == null) {
      return AppStrings.currentlyUnavailable;
    }
    int totalMinutes = 0;
    for (var entry in workingHours.entries) {
      final outTime = DateFormat("hh:mm a").parse(entry.value.outTime!);
      for (var logoutTime in timeModel.logOutDateList!) {
        final delay = DateTime(logoutTime.year, logoutTime.month, logoutTime.day, outTime.hour, outTime.minute).difference(logoutTime);
        if (!delay.isNegative) {
          totalMinutes += delay.inMinutes;
        }
      }
    }
    return formatDelay(totalMinutes);
  }

  // تنسيق عرض التأخير بالساعات والدقائق
  String formatDelay(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) {
      return "$minutes  ${AppStrings.minutes}";
    } else if (minutes == 0) {
      return "$hours ${AppStrings.hours}";
    } else {
      return "$hours ${AppStrings.hours} ${AppStrings.and} $minutes ${AppStrings.minutes}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.userControlPanel.tr),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${AppStrings.userName.tr} : ${user.userName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("${AppStrings.workStatus.tr}: ${user.userWorkStatus?.label}", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text("${AppStrings.status.tr}: ${user.userActiveStatus?.label}", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => VerticalSpace(),
                    itemCount: user.userTimeModel?.length ?? 0,
                    itemBuilder: (context, index) {
                      final userTimeModel = user.userTimeModel!.values.elementAt(index);
                      return Column(
                        children: [
                          Text(userTimeModel.dayName.toString()),
                          Text("${AppStrings.totalLoginDelay.tr}: ${calculateTotalLoginDelay(user.userWorkingHours!, userTimeModel)}"),
                          Text("${AppStrings.totalLateCheckOut.tr}: ${calculateTotalLogoutDelay(user.userWorkingHours!, userTimeModel)}"),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}