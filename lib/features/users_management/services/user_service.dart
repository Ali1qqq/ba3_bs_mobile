import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserService {
  UserModel? createUserModel({
    UserModel? userModel,
    required String userName,
    required String userPassword,
    String? userRoleId,
    String? userSellerId,
    Map<String, UserWorkingHours>? workingHour,
    List<String>? holidays,
    required UserActiveStatus userActiveState,
  }) {
    if (userRoleId == null || userSellerId == null) {
      return null;
    }

    final UserModel newUserModel;

    if (userModel == null) {
      newUserModel = UserModel(
          userName: userName,
          userPassword: userPassword,
          userRoleId: userRoleId,
          userSellerId: userSellerId,
          userWorkingHours: workingHour,
          userHolidays: holidays,
          userActiveStatus: userActiveState);
    } else {
      newUserModel = userModel.copyWith(
          userName: userName,
          userPassword: userPassword,
          userRoleId: userRoleId,
          userSellerId: userSellerId,
          userWorkingHours: workingHour,
          userHolidays: holidays,
          userActiveStatus: userActiveState);
    }
    return newUserModel;
  }

  String? calculateTotalDelay({
    required Map<String, UserWorkingHours> workingHours,
    required UserTimeModel? timeModel,
    required bool isLogin,
  }) {
    final dateList = isLogin ? timeModel?.logInDateList : timeModel?.logOutDateList;
    if (dateList == null) {
      return AppStrings.notLoggedToday.tr;
    }
    if (workingHours.isEmpty) {
      return 'لم يتم تسجيل الدوام له';
    }

    int totalMinutes = 0;

    for (int i = 0; i < dateList.length; i++) {
      final workingTime = isLogin ? workingHours.values.elementAtOrNull(i)?.enterTime : workingHours.values.elementAtOrNull(i)?.outTime;

      if (workingTime == null) {
        continue;
      }

      // تحويل الوقت المحدد (الدخول أو الخروج) إلى كائن DateTime
      final workingDateTime = DateFormat("hh:mm a").tryParse(workingTime) ?? DateFormat("a hh:mm").parse(workingTime);

      final userDateTime = dateList.elementAt(i);

      // حساب الفرق بناءً على نوع العملية (دخول أو خروج)
      final delay = isLogin
          ? userDateTime.difference(DateTime(
              userDateTime.year,
              userDateTime.month,
              userDateTime.day,
              workingDateTime.hour,
              workingDateTime.minute + 4,
            ))
          : DateTime(
              userDateTime.year,
              userDateTime.month,
              userDateTime.day,
              workingDateTime.hour,
              workingDateTime.minute - 4,
            ).difference(userDateTime);

      // إضافة الفرق إذا لم يكن سالبًا
      if (!delay.isNegative) {
        totalMinutes += delay.inMinutes;
      }
    }

    // إرجاع النتيجة المنسقة إذا كان هناك تأخير
    return totalMinutes > 0 ? formatDelay(totalMinutes) : null;
  }

  String formatDelay(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) {
      return "$minutes دقائق";
    } else if (minutes == 0) {
      return "$hours ساعات";
    } else {
      return "$hours ساعات و $minutes دقائق";
    }
  }

  bool getIfHaveHoliday(String dayName, List<String> userHolidays) {
    return userHolidays.contains(dayName);
  }
}