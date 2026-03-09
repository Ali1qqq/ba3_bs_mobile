import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ntp/ntp.dart';
import '../../users_management/data/models/user_model.dart';

class UserTimeServices {
  static const Duration gracePeriod = Duration(minutes: 15);
  // static const Duration autoLogoutAfter = Duration(hours: 3); // خروج تلقائي

  DateTime? _networkNow;

  Future<void> init() async {
    final nowNtp = await NTP.now();
    final utc = nowNtp.toUtc().add(const Duration(hours: 4));

    DateTime result = DateTime(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
      utc.millisecond,
      utc.microsecond,
    );

    print("Network now: $result");
    _networkNow = result;
    now = _networkNow ?? DateTime.now();
  }

  late DateTime now;

  UserTimeServices() {
    now = _networkNow ?? DateTime.now();
  }

  String get todayKey => DateFormat('yyyy-MM-dd').format(now);
  String get yesterdayKey =>
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

  // ====================== الدالة الرئيسية ======================
  UserModel toggleCheckInOut(UserModel user) {
    UserModel updated = user.copyWith();
    // 1. إغلاق اليوم السابق تلقائياً إذا لزم الأمر
    updated = _autoCloseYesterday(updated);

    // 2. معالجة اليوم الحالي
    return _processToday(updated);
  }

  // =============================================================
  UserModel _autoCloseYesterday(UserModel user) {
    print(now);

    final yesterdayModel = user.userTimeModel?[yesterdayKey];

    // 1.إغلاق اليوم السابق تلقائياً إذا لزم الأمر
    if (yesterdayModel == null) return user;

    final logIns = yesterdayModel.logInDateList ?? [];
    final logOuts = yesterdayModel.logOutDateList ?? [];
    // 2.إغلاق اليوم السابق تلقائياً إذا لزم الأمر
    if (logIns.length <= logOuts.length) return user;

    final lastLogin = logIns.last;

    final shifts = getSortedShifts(user);

    final normalizedLogin = _normalizeLoginTime(shifts, lastLogin);

    final activeShift = _getShiftForLogin(shifts, normalizedLogin);

    final scheduledOut = _getScheduledOutTime(activeShift, normalizedLogin);

    final maxAllowedTime = DateTime(
      lastLogin.year,
      lastLogin.month,
      lastLogin.day + 1,
      2,
      10,
    );

    DateTime logoutTime;
    int extraMinutes = yesterdayModel.totalExtraMinutes ?? 0;
    final activeIndexShift =
        shifts.indexWhere((shift) => shift.enterTime == activeShift.enterTime);

    // الحالة 1: قبل 2 فجراً
    if (now.isBefore(maxAllowedTime)) {
      logoutTime = now;
      if (logoutTime.isAfter(scheduledOut) &&
          activeIndexShift == shifts.length - 1) {
        final lastoutTime = _getScheduledOutTime(shifts.last, normalizedLogin);

        extraMinutes +=
            secondsToMinutesCeil(logoutTime.difference(lastoutTime).inSeconds);
      }
    }
    // الحالة 2: نسي تسجيل خروج
    else {
      logoutTime = scheduledOut;
    }

    var workedMinutes = 0;
    if (now.isAfter(lastLogin)) {
      workedMinutes = secondsToMinutesCeil(
          scheduledOut.difference(normalizedLogin).inSeconds);
    }
    int newOutEarlier = yesterdayModel.totalOutEarlier ?? 0;

    if (workedMinutes > 0) {
      newOutEarlier -= workedMinutes;
      if (newOutEarlier < 0) newOutEarlier = 0;
    }

    final updatedYesterday = yesterdayModel.copyWith(
        logOutDateList: [...logOuts, logoutTime],
        totalExtraMinutes: extraMinutes,
        totalOutEarlier: newOutEarlier);

    final newMap = Map<String, UserTimeModel>.from(user.userTimeModel ?? {});
    newMap[yesterdayKey] = updatedYesterday;

    return user.copyWith(userTimeModel: newMap);
  }

  UserModel _processToday(UserModel user) {
    final dayModel = user.userTimeModel?[todayKey];
    final shifts = getSortedShifts(user);

    // تسجيل دخول لاول مرة خلال اليوم
    if (dayModel == null) {
      return _firstLogin(user, shifts);
    }

    final isCheckedIn = (dayModel.logInDateList?.length ?? 0) >
        (dayModel.logOutDateList?.length ?? 0);
    // تسجيل خروج او تسجيل دخول خلال اليوم
    return isCheckedIn
        ? _doCheckout(user, dayModel, shifts)
        : _doCheckin(user, dayModel, shifts);
  }

  //أول دخول
  UserModel _firstLogin(UserModel user, List<UserWorkingHours> shifts) {
    if (!validateLoginTime(shifts)) {
      return user;
    }
    // حساب وقت الدوام الكامل لليوم
    final totalShiftMinutes = _getTotalScheduledMinutes(shifts);

    final newMap = Map<String, UserTimeModel>.from(user.userTimeModel ?? {});

    //  معالجة الأيام السابقة بنفس الشهر
    final startOfMonth = DateTime(now.year, now.month, 1);

    for (DateTime day = startOfMonth;
        day.isBefore(DateTime(now.year, now.month, now.day));
        day = day.add(const Duration(days: 1))) {
      final monthDay = DateFormat('MM-dd').format(day);
      // تحقق اذا كانت اليوم عطلة
      final isHoliday = user.userHolidays?.any((h) =>
              DateFormat('MM-dd').format(DateTime.parse(h)) == monthDay) ??
          false;

      final key = DateFormat('yyyy-MM-dd').format(day);
      // تحقق اذا كانت اليوم موجود مسبقا بايام الدوام
      final alreadyExists = newMap.containsKey(key);

      if (!isHoliday && !alreadyExists) {
        List<UserWorkingHours> shiftsToday =
            _getWorkTimeModel(user, isFriday: day.weekday == DateTime.friday);
        final totalShiftMinutesToday = _getTotalScheduledMinutes(shiftsToday);
        newMap[key] = UserTimeModel(
          dayName: key,
          logInDateList: [],
          logOutDateList: [],
          totalLogInDelay: totalShiftMinutesToday, // تأخير كامل
          totalOutEarlier: 0,
          totalExtraMinutes: 0,
        );
      }
    }

    final normalizedLogin = _normalizeLoginTime(shifts, now);
    final activeShift = _getShiftForLogin(shifts, normalizedLogin);
    final activeIndexShift =
        shifts.indexWhere((shift) => shift.enterTime == activeShift.enterTime);
    //حساب التاخير للشفت الحالي
    int delay = normalizedLogin
        .difference(_parseTimeOfDay(activeShift.enterTime!, now))
        .inMinutes;
    //حساب التاخير في حال عدم حضور الشفتات السابقة
    for (int i = 0; i < activeIndexShift; i++) {
      delay += _parseTimeOfDay(shifts[i].outTime!, now)
          .difference(_parseTimeOfDay(shifts[i].enterTime!, now))
          .inMinutes;
    }
    final newDay = UserTimeModel(
      dayName: todayKey,
      logInDateList: [now],
      logOutDateList: [],
      totalLogInDelay: delay < 0 ? 0 : delay,
      totalOutEarlier:
          (totalShiftMinutes - delay) < 0 ? 0 : totalShiftMinutes - delay,
      totalExtraMinutes: 0,
    );

    newMap[todayKey] = newDay;

    return user.copyWith(
      userTimeModel: newMap,
      userWorkStatus: UserWorkStatus.online,
    );
  }

  UserModel _doCheckin(
      UserModel user, UserTimeModel dayModel, List<UserWorkingHours> shifts) {
    if (!validateLoginTime(shifts)) {
      return user;
    }
    final normalizedLogin = _normalizeLoginTime(shifts, now);
    final activeShift = _getShiftForLogin(shifts, normalizedLogin);

    int delay = normalizedLogin
        .difference(_parseTimeOfDay(activeShift.enterTime!, now))
        .inMinutes;
    //تصفير التاخير في حال تسجيل التاخير لهذا الشفت مسبقا
    for (int i = 0;
        i < user.userTimeModel![todayKey]!.logOutDateList!.length;
        i++) {
      if (!dayModel.logOutDateList![i]
              .isAfter(_parseTimeOfDay(activeShift.outTime!, now)) &&
          !dayModel.logInDateList![i]
              .isBefore(_parseTimeOfDay(activeShift.enterTime!, now))) {
        delay = 0;
        break;
      }
    }

    final updatedDay = dayModel.copyWith(
      logInDateList: [...(dayModel.logInDateList ?? []), now],
      totalLogInDelay: dayModel.totalLogInDelay! + (delay > 0 ? delay : 0),
      totalOutEarlier: (dayModel.totalOutEarlier! - (delay > 0 ? delay : 0)) < 0
          ? 0
          : (dayModel.totalOutEarlier! - (delay > 0 ? delay : 0)),
    );

    final newMap = Map<String, UserTimeModel>.from(user.userTimeModel ?? {});
    newMap[todayKey] = updatedDay;

    return user.copyWith(
      userTimeModel: newMap,
      userWorkStatus: UserWorkStatus.online,
    );
  }

  UserModel _doCheckout(
      UserModel user, UserTimeModel dayModel, List<UserWorkingHours> shifts) {
    final lastLogin = dayModel.logInDateList!.last;
    final normalizedLogin = _normalizeLoginTime(shifts, lastLogin);

    final activeShift = _getShiftForLogin(shifts, normalizedLogin);

    final scheduledOut = _getScheduledOutTime(activeShift, normalizedLogin);

    var workedMinutes = 0;
    //حساب وقت الحضور الفعلي بين اخر تسجيل للدخول والوقت الحالي
    if (now.isAfter(lastLogin)) {
      // لضمان عدم التلاعب بالوقت
      //السماح بالخروج المبكر قبل 15 دقايق من وقت الخروج النهائي
      if (now.isAfter(scheduledOut.subtract(const Duration(minutes: 16)))) {
        workedMinutes = secondsToMinutesCeil(
            scheduledOut.difference(normalizedLogin).inSeconds);
      } else {
        workedMinutes =
            secondsToMinutesCeil(now.difference(normalizedLogin).inSeconds);
      }
    }
    int newOutEarlier = dayModel.totalOutEarlier ?? 0;

    if (workedMinutes > 0) {
      newOutEarlier -= workedMinutes;
      if (newOutEarlier < 0) newOutEarlier = 0;
    }

    final updatedDay = dayModel.copyWith(
      totalOutEarlier: newOutEarlier,
      logOutDateList: [...(dayModel.logOutDateList ?? []), now],
    );

    final newMap = Map<String, UserTimeModel>.from(user.userTimeModel ?? {});
    newMap[todayKey] = updatedDay;

    return user.copyWith(
      userTimeModel: newMap,
      userWorkStatus: UserWorkStatus.away,
    );
  }

  UserWorkingHours _getShiftForLogin(
    List<UserWorkingHours> shifts,
    DateTime loginTime,
  ) {
    for (var shift in shifts) {
      final start = _parseTimeOfDay(shift.enterTime!, loginTime);
      final end = _getScheduledOutTime(shift, loginTime);

      if (!loginTime.isBefore(start) && loginTime.isBefore(end)) {
        return shift;
      }
    }

    // fallback احتياطي
    return shifts.last;
  }

  //نحسب كامل وقت الدوام لليوم
  int _getTotalScheduledMinutes(List<UserWorkingHours> shifts) {
    int total = 0;
    for (var shift in shifts) {
      final start = _parseTimeOfDay(shift.enterTime!, now);
      final end = _getScheduledOutTime(shift, now);

      total += end.difference(start).inMinutes;
    }

    return total;
  }

  /*
  دالة تضبط وقت الدخول إذا كان

  قبل بداية الشفت  -    

  أو ضمن فترة السماح  -
  */
  DateTime _normalizeLoginTime(
      List<UserWorkingHours> shifts, DateTime loginTime) {
    for (var shift in shifts) {
      final start = _parseTimeOfDay(shift.enterTime!, loginTime);
      final allowed = start.add(gracePeriod);
      final end = _getScheduledOutTime(shift, loginTime);

      if (loginTime.isBefore(start)) {
        return start;
      }

      if (loginTime.isAfter(start) && loginTime.isBefore(allowed)) {
        return start;
      }

      if (loginTime.isBefore(end)) {
        return loginTime;
      }
    }

    return loginTime;
  }

  int secondsToMinutesCeil(int seconds) {
    return (seconds / 60).ceil();
  }

  //دالة التحقق من وقت الدخول
  bool validateLoginTime(List<UserWorkingHours> shifts) {
    DateTime loginTime = now;
    final normalizedLogin = _normalizeLoginTime(shifts, loginTime);

    final activeShift = _getShiftForLogin(shifts, normalizedLogin);

    final start = _parseTimeOfDay(activeShift.enterTime!, loginTime);
    final end = _getScheduledOutTime(activeShift, loginTime);

    final allowedBefore = start.subtract(const Duration(minutes: 15));

    if (loginTime.isBefore(allowedBefore)) {
      return false;
    }

    if (loginTime.isAfter(allowedBefore) && loginTime.isBefore(end)) {
      return true; // مسموح
    }

    return false;
  }

  // تحديد ساعات العمل (جمعة أو باقي الأيام)
  List<UserWorkingHours> _getWorkTimeModel(UserModel userModel,
      {bool? isFriday}) {
    if (isFriday != null) {
      return isFriday
          ? AppConstants.fridayWorkingHours
          : userModel.userWorkingHours!.values.toList();
    }
    return DateTime.now().weekday == DateTime.friday
        ? AppConstants.fridayWorkingHours
        : userModel.userWorkingHours!.values.toList();
  }

  // ====================== تعديل الدوال الرئيسية ======================

  DateTime _parseTimeOfDay(String timeStr, DateTime base) {
    final clean = timeStr.trim().toUpperCase();

    // حالة خاصة: 12:00 AM = نهاية اليوم = منتصف الليل من اليوم التالي
    if (clean == "12:00 AM" ||
        clean == "12:00AM" ||
        clean.contains("12:00 AM")) {
      return DateTime(base.year, base.month, base.day + 1, 0, 0);
    }

    final dt = DateFormat("hh:mm a").parse(timeStr);
    return DateTime(base.year, base.month, base.day, dt.hour, dt.minute);
  }

  DateTime _getScheduledOutTime(UserWorkingHours shift, DateTime base) {
    final outStr = (shift.outTime!).trim().toUpperCase();

    // حالة خاصة واضحة
    if (outStr == "12:00 AM" || outStr == "12:00AM") {
      return DateTime(base.year, base.month, base.day + 1, 0, 0); // نهاية اليوم
    }

    var outTime = _parseTimeOfDay(shift.outTime!, base);
    final enterTime = _parseTimeOfDay(shift.enterTime!, base);

    // القاعدة العامة: إذا خرج الوقت قبل وقت الدخول → يعني اليوم التالي
    if (outTime.isBefore(enterTime)) {
      outTime = outTime.add(const Duration(days: 1));
    }

    return outTime;
  }

  List<UserWorkingHours> getSortedShifts(UserModel user) {
    final shifts = _getWorkTimeModel(user);
    shifts.sort(
        (a, b) => _parseTime(a.enterTime!).compareTo(_parseTime(b.enterTime!)));
    return shifts;
  }

  DateTime _parseTime(String time) => DateFormat("hh:mm a").parse(time);
  bool isWithinRegion(Position location, double targetLatitude,
      double targetLongitude, double radiusInMeters) {
    double distanceInMeters = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distanceInMeters <= radiusInMeters;
  }
}
