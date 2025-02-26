import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../core/helper/enums/enums.dart';
import '../../users_management/data/models/user_model.dart';

class UserTimeServices {
  DateTime getCurrentTime() => Timestamp.now().toDate();

  String getCurrentDayName() => getCurrentTime().dayMonthYear;

  // add user logIn time
  UserModel addLoginTimeToUserModel({required UserModel userModel}) {
    final currentDay = getCurrentDayName();
    final currentTime = getCurrentTime();

    // Get the current day's time model, if it exists
    final currentDayModel = userModel.userTimeModel?[currentDay];

    if (currentDayModel != null) {
      // Create an updated list by merging the existing login times with the new time
      final List<DateTime> updatedLogInDateList = [
        ...currentDayModel.logInDateList ?? [],
        currentTime,
      ];

      // Update the day's model with the new list and calculated delay
      final updatedTimeModel = currentDayModel.copyWith(
        logInDateList: updatedLogInDateList,
        totalLogInDelay: calculateTotalDelay(
          workingHours: userModel.userWorkingHours!.values.toList(),
          timeModel: currentDayModel.copyWith(
            logInDateList: updatedLogInDateList,
          ),
          isLogin: true,
        ),
      );

      userModel.userTimeModel![currentDay] = updatedTimeModel;
    } else {
      // Create a new time model for the day with the current time
      final newTimeModel = UserTimeModel(
        dayName: currentDay,
        logInDateList: [currentTime],
        totalLogInDelay: calculateTotalDelay(
          workingHours: userModel.userWorkingHours!.values.toList(),
          timeModel: UserTimeModel(dayName: currentDay, logInDateList: [currentTime]),
          isLogin: true,
        ),
      );
      userModel.userTimeModel![currentDay] = newTimeModel;
    }

    return userModel.copyWith(userWorkStatus: UserWorkStatus.online);
  }

  UserModel addLogOutTimeToUserModel({required UserModel userModel}) {
    final currentDay = getCurrentDayName();
    final currentTime = getCurrentTime();

    // Get the current day's time model, if it exists
    final currentDayModel = userModel.userTimeModel?[currentDay];

    if (currentDayModel != null) {
      // Create an updated list by merging the existing logout times with the new time
      final List<DateTime> updatedLogOutDateList = [
        ...currentDayModel.logOutDateList ?? [],
        currentTime,
      ];

      // Update the day's model with the new list and calculated delay
      final updatedTimeModel = currentDayModel.copyWith(
        logOutDateList: updatedLogOutDateList,
        totalOutEarlier: calculateTotalDelay(
          workingHours: userModel.userWorkingHours!.values.toList(),
          timeModel: currentDayModel.copyWith(
            logOutDateList: updatedLogOutDateList,
          ),
          isLogin: false,
        ),
      );

      userModel.userTimeModel![currentDay] = updatedTimeModel;
    } else {
      // Create a new time model for the day with the current time
      final newTimeModel = UserTimeModel(
        dayName: currentDay,
        logOutDateList: [currentTime],
        totalOutEarlier: calculateTotalDelay(
          workingHours: userModel.userWorkingHours!.values.toList(),
          timeModel: UserTimeModel(dayName: currentDay, logOutDateList: [currentTime]),
          isLogin: false,
        ),
      );
      userModel.userTimeModel![currentDay] = newTimeModel;
    }

    return userModel.copyWith(userWorkStatus: UserWorkStatus.away);
  }

  List<DateTime>? getEnterTimes(UserModel? userModel) {
    return userModel?.userTimeModel![getCurrentDayName()]?.logInDateList;
  }

  List<DateTime>? getOutTimes(UserModel? userModel) {
    return userModel?.userTimeModel![getCurrentDayName()]?.logOutDateList;
  }

  bool isWithinRegion(Position location, double targetLatitude, double targetLongitude, double radiusInMeters) {
    double distanceInMeters = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distanceInMeters <= radiusInMeters;
  }

  int? calculateTotalDelay({
    required List<UserWorkingHours> workingHours,
    required UserTimeModel? timeModel,
    required bool isLogin,
  }) {
    final dateList = isLogin ? timeModel?.logInDateList : timeModel?.logOutDateList;
    if (dateList == null) {
      return 0;
    }
    if (workingHours.isEmpty) {
      return 0;
    }

    int totalMinutes = 0;

    for (int i = 0; i < dateList.length; i++) {
      final workingTime = isLogin ? workingHours.elementAtOrNull(i)?.enterTime : workingHours.elementAtOrNull(i)?.outTime;

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
              workingDateTime.minute + 10,
            ))
          : DateTime(
              userDateTime.year,
              userDateTime.month,
              userDateTime.day,
              workingDateTime.hour,
              workingDateTime.minute - 10,
            ).difference(userDateTime);

      // إضافة الفرق إذا لم يكن سالبًا
      if (!delay.isNegative) {
        totalMinutes += delay.inMinutes;
      }
    }

    // إرجاع النتيجة المنسقة إذا كان هناك تأخير
    return totalMinutes > 0 ? totalMinutes : 0;
  }
}