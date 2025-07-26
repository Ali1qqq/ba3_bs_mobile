import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../users_management/data/models/user_model.dart';

class UserTimeServices {
  /// يُرجع التاريخ والوقت الحالي بناءً على خادم Firebase
  DateTime getCurrentTime() => Timestamp.now().toDate();

  /// يُرجع اسم اليوم الحالي بشكل 'yyyy-MM-dd'
  String getCurrentDayName() => getCurrentTime().dayMonthYear;

  /// يحاول تحويل وقت العمل من String إلى DateTime مع دعم تنسيقات متعددة

  UserModel addLoginTimeToUserModel({required UserModel userModel}) {
    final currentDay = getCurrentDayName();
    final currentTime = getCurrentTime();

    userModel.userTimeModel ??= {};

    final currentDayModel = userModel.userTimeModel?[currentDay];

    if (currentDayModel != null) {
      final updatedLogInDateList = [
        ...?currentDayModel.logInDateList,
        currentTime,
      ];

      final updatedTimeModel = currentDayModel.copyWith(
        logInDateList: updatedLogInDateList,
        totalLogInDelay: calculateTotalDelay(
          workingHours: userModel.userWorkingHours?.values.toList() ?? [],
          timeModel: currentDayModel.copyWith(logInDateList: updatedLogInDateList),
          isLogin: true,
        ),
      );

      userModel.userTimeModel![currentDay] = updatedTimeModel;
    } else {
      final newTimeModel = UserTimeModel(
        dayName: currentDay,
        logInDateList: [currentTime],
        totalLogInDelay: calculateTotalDelay(
          workingHours: userModel.userWorkingHours?.values.toList() ?? [],
          timeModel: UserTimeModel(dayName: currentDay, logInDateList: [currentTime]),
          isLogin: true,
        ),
      );

      userModel.userTimeModel![currentDay] = newTimeModel;
    }

    return userModel.copyWith(userWorkStatus: UserWorkStatus.online);
  }

  UserModel addLogOutTimeToUserModel({required UserModel userModel}) {
    final currentTime = getCurrentTime();
    final currentDayKey = getCurrentDayName();

    final yesterday = currentTime.subtract(const Duration(days: 1));
    final yesterdayKey = DateFormat('yyyy-MM-dd').format(yesterday);

    userModel.userTimeModel ??= {};

    final todayModel = userModel.userTimeModel?[currentDayKey];
    final yesterdayModel = userModel.userTimeModel?[yesterdayKey];

    final isLateNight = currentTime.hour < 6;
    final hasYesterdayLogin = yesterdayModel?.logInDateList?.isNotEmpty ?? false;
    final hasYesterdayLogout = yesterdayModel?.logOutDateList?.isNotEmpty ?? false;

    /// ✅ 1. إذا نسي يسجل خروج أمس، وعم يسجل اليوم أو بعد منتصف الليل، سجل له تلقائي
    if (hasYesterdayLogin && !hasYesterdayLogout) {
      final autoLogOutTime = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59);
      final updatedYesterdayModel = yesterdayModel!.copyWith(
        logOutDateList: [autoLogOutTime],
        totalOutEarlier: 59,
      );

      userModel.userTimeModel![yesterdayKey] = updatedYesterdayModel;

      AppUIUtils.onInfo(
        "تم تسجيل خروجك تلقائيًا ليوم $yesterdayKey الساعة 11:59 PM بسبب نسيان تسجيل الخروج.",
        "تم تسجيل الخروج تلقائيًا",
      );
    }

    /// ✅ 2. إذا نحن في وقت متأخر من الليل ونحتاج نربط الخروج مع أمس
    if (isLateNight && hasYesterdayLogin && !hasYesterdayLogout) {
      final updatedModel = _buildUpdatedTimeModel(
        userModel: userModel,
        dayKey: yesterdayKey,
        logOuts: [currentTime],
        baseModel: yesterdayModel,
      );

      userModel.userTimeModel![yesterdayKey] = updatedModel;

      AppUIUtils.onInfo(
        "تم تسجيل الخروج لدوام يوم $yesterdayKey بعد منتصف الليل.",
        "خروج محسوب لليوم السابق",
      );

      return userModel.copyWith(userWorkStatus: UserWorkStatus.away);
    }

    /// ✅ 3. إذا كان اليوم الحالي ما فيه دخول، بس أمس فيه دخولين وخروج واحد، وسجل المستخدم خروج جديد بعد منتصف الليل
    if ((todayModel?.logInDateList?.isEmpty ?? true) &&
        (yesterdayModel?.logInDateList?.length == 2) &&
        ((yesterdayModel?.logOutDateList?.length ?? 0) == 1)) {
      final updatedYesterdayLogOuts = [...?yesterdayModel!.logOutDateList, currentTime];

      final updatedYesterdayModel = _buildUpdatedTimeModel(
        userModel: userModel,
        dayKey: yesterdayKey,
        logOuts: updatedYesterdayLogOuts,
        baseModel: yesterdayModel,
      );

      userModel.userTimeModel![yesterdayKey] = updatedYesterdayModel;

      AppUIUtils.onInfo(
        "تم تسجيل الخروج الثاني تلقائيًا ليوم $yesterdayKey بعد منتصف الليل.",
        "خروج محسوب لليوم السابق",
      );

      return userModel.copyWith(userWorkStatus: UserWorkStatus.away);
    }

    /// ✅ 4. تسجيل الخروج لليوم الحالي (بما في ذلك الخروج التلقائي للاستراحة)
    final currentModel = todayModel ?? UserTimeModel(dayName: currentDayKey);
    final logIns = currentModel.logInDateList ?? [];
    final logOuts = currentModel.logOutDateList ?? [];

    if (logIns.length == 1 && logOuts.isEmpty && (userModel.userWorkingHours?.length ?? 0) > 1) {
      final firstLogin = logIns.first;

      final firstShiftEnd = parseWorkingTime(
        userModel.userWorkingHours!.values.toList()[0].outTime!,
        referenceDate: firstLogin,
      );

      if (firstShiftEnd != null && currentTime.isAfter(firstShiftEnd.add(const Duration(minutes: 10)))) {
        // ✅ نسجل الخروج فقط عند نهاية الشفت الأول بدون احتساب خروج مبكر أو إضافي
        final updatedLogOuts = [...logOuts, firstShiftEnd];

        final updatedTimeModel = currentModel.copyWith(
          logOutDateList: updatedLogOuts,
          totalOutEarlier: 0,
          totalExtraMinutes: 0,
        );

        userModel.userTimeModel![currentDayKey] = updatedTimeModel;

        AppUIUtils.onInfo(
          "تم تسجيل خروجك تلقائيًا الساعة ${DateFormat.Hm().format(firstShiftEnd)} لنهاية الشفت الأول.",
          "خروج تلقائي بعد نسيان الخروج",
        );

        return userModel.copyWith(userWorkStatus: UserWorkStatus.away);
      }
    }

    /// ✅ 5. تسجيل خروج عادي لليوم الحالي
    final updatedLogOuts = [...logOuts, currentTime];

    final updatedFinalModel = _buildUpdatedTimeModel(
      userModel: userModel,
      dayKey: currentDayKey,
      logOuts: updatedLogOuts,
      baseModel: currentModel,
    );

    // ✅ تحقق إذا لا يوجد دخول اليوم الحالي، لا تسجل خروج لهذا اليوم
    if ((currentModel.logInDateList?.isEmpty ?? true)) {
      log("لا يوجد دخول اليوم، لن يتم تسجيل خروج", name: 'AddLogOut');
      return userModel;
    }

    userModel.userTimeModel![currentDayKey] = updatedFinalModel;

    return userModel.copyWith(userWorkStatus: UserWorkStatus.away);
  }

  DateTime? parseWorkingTime(String time, {required DateTime referenceDate}) {
    final formats = ["hh:mm a", "a hh:mm"];

    for (final format in formats) {
      try {
        final parsedTime = DateFormat(format).parse(time);

        DateTime result = DateTime(
          referenceDate.year,
          referenceDate.month,
          referenceDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );

        // إذا الوقت هو 00:00 (منتصف الليل)، نخليه لليوم التالي لأنه نهاية دوام
        if (parsedTime.hour == 0 && parsedTime.minute == 0) {
          result = result.add(const Duration(days: 1));
        }

        return result;
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  UserTimeModel _buildUpdatedTimeModel({
    required UserModel userModel,
    required String dayKey,
    required List<DateTime> logOuts,
    required UserTimeModel? baseModel,
  }) {
    return baseModel!.copyWith(
      logOutDateList: logOuts,
      totalOutEarlier: calculateTotalDelay(
        workingHours: userModel.userWorkingHours?.values.toList() ?? [],
        timeModel: baseModel.copyWith(logOutDateList: logOuts),
        isLogin: false,
      ),
    );
  }

  /// يحسب إجمالي التأخير أو الخروج المبكر بالـ دقائق اعتماداً على أوقات العمل وسجلات الدخول/الخروج
  ///
  /// [workingHours] قائمة أوقات دوام الموظف (دخول وخروج)
  /// [timeModel] سجل أوقات الدخول أو الخروج لليوم
  /// [isLogin] true لحساب تأخير الدخول، false لحساب الخروج المبكر
  /// [gracePeriodMinutes] فترة السماح (10 دقائق افتراضياً)
  int calculateTotalDelay({
    required List<UserWorkingHours> workingHours,
    required UserTimeModel? timeModel,
    required bool isLogin,
    int gracePeriodMinutes = 10,
  }) {
    final List<UserWorkingHours> currentWorkingHours = AppServiceUtils.isFriday() ? AppConstants.fridayWorkingHours : workingHours;
    final dateList = isLogin ? timeModel?.logInDateList : timeModel?.logOutDateList;
    if (dateList == null || currentWorkingHours.isEmpty) return 0;

    int totalMinutes = 0;

    for (int i = 0; i < dateList.length; i++) {
      final workingTime =
          (i < currentWorkingHours.length) ? (isLogin ? currentWorkingHours[i].enterTime : currentWorkingHours[i].outTime) : null;
      if (workingTime == null) continue;

      final userDateTime = dateList[i];
      final workingDateTime = parseWorkingTime(workingTime, referenceDate: userDateTime);
      if (workingDateTime == null) continue;

      if (!isLogin) {
        // خروج

        DateTime expectedOutTime;

        // ✅ إذا كان وقت الخروج 00:00 (منتصف الليل) نعتبره اليوم التالي
        if (workingDateTime.hour == 0 && workingDateTime.minute == 0) {
          expectedOutTime = DateTime(
            userDateTime.year,
            userDateTime.month,
            userDateTime.day + 1,
            0,
            0 - gracePeriodMinutes,
          );
        } else {
          expectedOutTime = DateTime(
            userDateTime.year,
            userDateTime.month,
            userDateTime.day,
            workingDateTime.hour,
            workingDateTime.minute - gracePeriodMinutes,
          );
        }

        // ✅ إذا كان الخروج بعد منتصف الليل وقبل 6 صباحًا، تجاهل حساب خروج مبكر
        if (userDateTime.hour < 6) {
          continue;
        }

        final early = expectedOutTime.difference(userDateTime).inMinutes;
        if (early > 0) {
          totalMinutes += early;
        }
      } else {
        // دخول
        final expectedInTime = DateTime(
          userDateTime.year,
          userDateTime.month,
          userDateTime.day,
          workingDateTime.hour,
          workingDateTime.minute + gracePeriodMinutes,
        );

        final delay = userDateTime.difference(expectedInTime).inMinutes;
        if (delay > 0) {
          totalMinutes += delay;
        }
      }
    }

    return totalMinutes > 0 ? totalMinutes : 0;
  }

  /// يُرجع قائمة أوقات الدخول ليوم العمل الحالي (أو null)
  List<DateTime>? getEnterTimes(UserModel? userModel) {
    return userModel?.userTimeModel?[getCurrentDayName()]?.logInDateList;
  }

  /// يُرجع قائمة أوقات الخروج ليوم العمل الحالي (أو null)
  List<DateTime>? getOutTimes(UserModel? userModel) {
    return userModel?.userTimeModel?[getCurrentDayName()]?.logOutDateList;
  }

  /// يتحقق إذا كان الموقع الجغرافي ضمن منطقة محددة (نقطة مركز ونصف قطر)
  bool isWithinRegion(Position location, double targetLatitude, double targetLongitude, double radiusInMeters) {
    double distanceInMeters = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distanceInMeters <= radiusInMeters;
  }
}