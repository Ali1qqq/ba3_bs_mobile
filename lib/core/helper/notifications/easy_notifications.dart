import 'dart:async';

import 'package:easy_notifications/easy_notifications.dart';
import 'package:intl/intl.dart';

bool isHoliday(DateTime date, List<String> holidays) {
  final dateStr = DateFormat('yyyy-MM-dd').format(date);
  return holidays.contains(dateStr);
}

DateTime parseTime(String timeStr) {
  final now = DateTime.now();
  final format = DateFormat("hh:mm a");
  final time = format.parse(timeStr);
  return DateTime(now.year, now.month, now.day, time.hour, time.minute);
}

void scheduleLoginNotification({
  required String time,
  required String userName,
  required String title,
  required bool isLogin,
  required List<String> holidays,
}) {
  DateTime timeDate = parseTime(time);
  final now = DateTime.now();

  if (isLogin) {
    timeDate = timeDate.copyWith(minute: timeDate.minute + 10);
  } else {
    timeDate = timeDate.copyWith(minute: timeDate.minute - 10);
  }

  // إذا كان وقت الدخول المحدد قد مرّ اليوم، نضيف يومًا واحدًا
  if (timeDate.isBefore(now)) {
    timeDate = timeDate.add(Duration(days: 1));
  }

  // إذا كان يوم الدخول عطلة، نتخطاه حتى نحصل على يوم عمل
  while (isHoliday(timeDate, holidays)) {
    timeDate = timeDate.add(Duration(days: 1));
  }

  final durationUntilLogin = timeDate.difference(now);

  // جدولة المؤقت ليعرض الإشعار عند حلول وقت تسجيل الدخول
  Timer(durationUntilLogin, () {
    EasyNotifications.showMessage(
      title: title,
      message: 'حان وقت تسجيل الدخول، مرحباً $userName',
      body: '',
    );

    // إعادة جدولة الإشعار لليوم التالي أو اليوم التالي الغير عطلة
    scheduleLoginNotification(
      time: time,
      userName: userName,
      holidays: holidays,
      title: title,
      isLogin: isLogin,
    );
  });
}