import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../users_management/data/models/user_model.dart';

class UserTimeServices {
  DateTime getCurrentTime() => Timestamp.now().toDate();

  String getCurrentDayName() => getCurrentTime().dayMonthYear;

  String getLastDayName() => getCurrentTime().subtract(const Duration(days: 1)).dayMonthYear;
  Duration gracePeriod = Duration(minutes: 10);

  // add user logIn time
  UserModel smartCheckTime({required UserModel userModel}) {
    final currentDay = getCurrentDayName();
    final currentTime = getCurrentTime();
    final lastDay = getLastDayName();

    // ساعات الدوام (حسب اليوم)
    final userWorkTimeModel = _getWorkTimeModel(userModel);

    // تحقق إذا تجاوز عدد الدخول والخروج المسموح
    if (_exceededDailyLimits(userModel, userWorkTimeModel, currentDay)) {
      AppUIUtils.onFailure('لقد تجاوزت عدد الدخول و الخروج لهذا اليوم');
      return userModel;
    }

    // 1. التحقق من اليوم السابق
    final handledPrevious = _handlePreviousDay(userModel, userWorkTimeModel, currentDay, lastDay, currentTime);
    if (handledPrevious != null) return handledPrevious;

    // 2. التحقق من اليوم الحالي
    return _handleCurrentDay(userModel, userWorkTimeModel, currentDay, currentTime);
  }

  // تحديد ساعات العمل (جمعة أو باقي الأيام)
  List<UserWorkingHours> _getWorkTimeModel(UserModel userModel) {
    return DateTime.now().weekday == DateTime.friday ? AppConstants.fridayWorkingHours : userModel.userWorkingHours!.values.toList();
  }

// تحقق من تجاوز عدد الدخول/الخروج
  bool _exceededDailyLimits(UserModel userModel, List<UserWorkingHours> workTimes, String currentDay) {
    final dayModel = userModel.userTimeModel?[currentDay];
    return workTimes.length == (dayModel?.logInDateList?.length ?? 0) && workTimes.length == (dayModel?.logOutDateList?.length ?? 0);
  }

  // دالة لتحويل الوقت من String AM/PM إلى DateTime
  DateTime parseTime(String timeStr, DateTime day) {
    log(timeStr);
    final parts = timeStr.split(RegExp(r'[: ]'));
    int hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = parts[2].toUpperCase();
    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  UserModel? _handlePreviousDay(
    UserModel userModel,
    List<UserWorkingHours> workTimes,
    String currentDay,
    String lastDay,
    DateTime currentTime,
  ) {
    final lastDayModel = userModel.userTimeModel?[lastDay];
    if (lastDayModel == null) return null;

    final logins = lastDayModel.logInDateList ?? [];
    final logouts = lastDayModel.logOutDateList ?? [];

    if (!needsLogout(logins, logouts)) return null;

    if (currentTime.hour < 2) {
      // خروج متأخر (قبل 2 صباحاً)
      final updatedLogOuts = [...logouts, currentTime];
      final updatedDay = lastDayModel
          .copyWithAddTime(
            totalExtraMinutes: parseTime(workTimes.last.enterTime!, currentTime).difference(currentTime).inMinutes,
          )
          .copyWith(logOutDateList: updatedLogOuts);
      userModel.userTimeModel![lastDay] = updatedDay;
      return userModel.copyWith(userWorkStatus: UserWorkStatus.away);
    } else {
      // خروج افتراضي + دخول جديد
      final scheduledOut = parseTime(workTimes.last.outTime!, currentTime);
      final updatedLogOuts = [...logouts, scheduledOut];
      userModel.userTimeModel![lastDay] = lastDayModel.copyWith(logOutDateList: updatedLogOuts);

      final newDayModel = UserTimeModel(dayName: currentDay, logInDateList: [currentTime]);
      userModel.userTimeModel![currentDay] = newDayModel;

      return userModel.copyWith(userWorkStatus: UserWorkStatus.online);
    }
  }

  UserModel _handleCurrentDay(
    UserModel userModel,
    List<UserWorkingHours> workTimes,
    String currentDay,
    DateTime currentTime,
  ) {
    var currentDayModel = userModel.userTimeModel?[currentDay];

    // أول دخول
    if (currentDayModel == null) {
      return _handleFirstLogin(userModel, workTimes, currentDay, currentTime);
    }

    // أكثر من فترة عمل
    if (workTimes.length > 1) {
      return _handleMultiShift(userModel, workTimes, currentDay, currentTime, currentDayModel);
    }

    // فترة واحدة فقط
    return _handleSingleShift(userModel, workTimes, currentDay, currentTime, currentDayModel);
  }

  UserModel _handleFirstLogin(
    UserModel userModel,
    List<UserWorkingHours> workTimes,
    String currentDay,
    DateTime currentTime,
  ) {
    final newTimeModel = UserTimeModel(dayName: currentDay, logInDateList: [currentTime]);

    int totalDelay = 0;
    final scheduledEnter = parseTime(workTimes.first.enterTime!, currentTime);

    if (currentTime.isAfter(scheduledEnter.subtract(gracePeriod))) {
      totalDelay += calculateLateMinutes(currentTime, scheduledEnter);
    }

    userModel.userTimeModel![currentDay] = newTimeModel.copyWithAddTime(totalLogInDelay: totalDelay);

    return userModel.copyWith(userWorkStatus: UserWorkStatus.online);
  }

  UserModel _handleMultiShift(
    UserModel userModel,
    List<UserWorkingHours> workTimes,
    String currentDay,
    DateTime currentTime,
    UserTimeModel currentDayModel,
  ) {
    final logins = currentDayModel.logInDateList ?? [];
    final logouts = currentDayModel.logOutDateList ?? [];

    if (needsLogout(logins, logouts)) {
      // تسجيل خروج
      final updatedLogOuts = [...logouts, currentTime];
      int earlyMinutes = 0;

      final scheduledOut = parseTime(
        workTimes[logouts.length].outTime!,
        currentTime,
      );

      if (currentTime.isBefore(scheduledOut.subtract(gracePeriod))) {
        earlyMinutes += calculateLateMinutes(currentTime, scheduledOut);
      }

      // تحقق من الدخول التالي (±30 دقيقة)
      final nextEnter = parseTime(workTimes[1].enterTime!, currentTime);
      final diff = currentTime.difference(nextEnter).inMinutes;

      if (diff.abs() <= 30) {
        final updatedLogins = [...logins, currentTime];
        final updatedLogOuts = [...logouts, scheduledOut];

        int lateMinutes = 0;

        if (currentTime.isAfter(nextEnter.subtract(gracePeriod))) {
          lateMinutes += calculateLateMinutes(currentTime, nextEnter);
        }

        currentDayModel = currentDayModel
            .copyWithAddTime(totalLogInDelay: lateMinutes)
            .copyWith(logInDateList: updatedLogins, logOutDateList: updatedLogOuts);
        userModel.userTimeModel![currentDay] = currentDayModel;
        log(currentDayModel.logOutDateList.toString());
        log(currentDayModel.logInDateList.toString());
        return userModel.copyWith(userWorkStatus: UserWorkStatus.online);
      } else {
        currentDayModel = currentDayModel.copyWithAddTime(totalOutEarlier: earlyMinutes).copyWith(logOutDateList: updatedLogOuts);
        userModel.userTimeModel![currentDay] = currentDayModel;
        return userModel.copyWith(userWorkStatus: UserWorkStatus.away);
      }
    } else {
      // تسجيل دخول جديد
      final updatedLogins = [...logins, currentTime];
      int lateMinutes = 0;
      final nextEnter = parseTime(workTimes[1].enterTime!, currentTime);

      if (currentTime.isAfter(nextEnter.subtract(gracePeriod))) {
        lateMinutes += calculateLateMinutes(currentTime, nextEnter);
      }

      currentDayModel = currentDayModel.copyWithAddTime(totalLogInDelay: lateMinutes).copyWith(logInDateList: updatedLogins);
      userModel.userTimeModel![currentDay] = currentDayModel;

      return userModel.copyWith(userWorkStatus: UserWorkStatus.online);
    }
  }

  UserModel _handleSingleShift(
    UserModel userModel,
    List<UserWorkingHours> workTimes,
    String currentDay,
    DateTime currentTime,
    UserTimeModel currentDayModel,
  ) {
    final logouts = currentDayModel.logOutDateList ?? [];
    final updatedLogOuts = [...logouts, currentTime];

    int earlyMinutes = 0;
    final endOfDay = parseTime('11:59 PM', currentTime);

    if (currentTime.isBefore(endOfDay.subtract(gracePeriod))) {
      earlyMinutes += calculateEarlyLeaveMinutes(currentTime, endOfDay);
    }

    currentDayModel = currentDayModel.copyWithAddTime(totalOutEarlier: earlyMinutes).copyWith(logOutDateList: updatedLogOuts);

    userModel.userTimeModel![currentDay] = currentDayModel;

    return userModel.copyWith(userWorkStatus: UserWorkStatus.away);
  }

  int calculateLateMinutes(DateTime loginTime, DateTime periodStart) {
    final allowedStart = periodStart.add(gracePeriod);
    if (loginTime.isAfter(allowedStart)) {
      return loginTime.difference(allowedStart).inMinutes;
    }
    return 0;
  }

  int calculateEarlyLeaveMinutes(DateTime logoutTime, DateTime periodEnd) {
    final allowedEnd = periodEnd.subtract(gracePeriod);
    if (logoutTime.isBefore(allowedEnd)) {
      return allowedEnd.difference(logoutTime).inMinutes;
    }
    return 0;
  }

  bool needsLogout(List<DateTime>? logins, List<DateTime>? logouts) {
    final loginCount = logins?.length ?? 0;
    final logoutCount = logouts?.length ?? 0;
    return loginCount > logoutCount;
  }

/*  UserModel addLogOutTimeToUserModel({required UserModel userModel}) {
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
  }*/

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