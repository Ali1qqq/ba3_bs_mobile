// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:intl/intl.dart';
// // import 'package:timezone/data/latest.dart' as tz;
// // import 'package:timezone/timezone.dart' as tz;
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
// DateTime getScheduledTime(String timeStr) {
//   final now = DateTime.now();
//   final format = DateFormat.jm(); // صيغة "10:00 AM"
//   final parsedTime = format.parse(timeStr);
//   return DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
// }
//
// Future<void> scheduleNotification({
//   required int id,
//   required String title,
//   required String body,
//   required DateTime scheduledDate,
// }) async {
//   final now = DateTime.now();
//   // إذا كان الوقت المحدد قد مر، نضيف يومًا للتأكد من أن الإشعار سيظهر في المستقبل
//   if (scheduledDate.isBefore(now)) {
//     scheduledDate = scheduledDate.add(Duration(days: 1));
//   }
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     id,
//     title,
//     body,
//     tz.TZDateTime.from(scheduledDate, tz.local),
//     const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'channel_id',
//         'channel_name',
//         channelDescription: 'Description of the channel',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//     ),
//     androidScheduleMode:AndroidScheduleMode.inexact,
//     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     matchDateTimeComponents: DateTimeComponents.time, // لتكرار الإشعار يومياً بنفس التوقيت
//   );
// }
//
// void scheduleUserNotifications(Map<String, dynamic> userWorkingHours) {
//   // استخراج القوائم من الـ userWorkingHours
//   List<String> enterTimes = List<String>.from(userWorkingHours['enterTimes']);
//   List<String> outTimes = List<String>.from(userWorkingHours['outTimes']);
//
//   // جدولة إشعارات تسجيل الدخول
//   for (int i = 0; i < enterTimes.length; i++) {
//     DateTime loginTime = getScheduledTime(enterTimes[i]);
//     scheduleNotification(
//       id: i, // تأكد من أن كل إشعار له id فريد
//       title: 'تنبيه تسجيل الدخول',
//       body: 'حان وقت تسجيل الدخول، الرجاء تسجيل الدخول للتطبيق.',
//       scheduledDate: loginTime,
//     );
//   }
//
//   // جدولة إشعارات تسجيل الخروج
//   for (int i = 0; i < outTimes.length; i++) {
//     DateTime logoutTime = getScheduledTime(outTimes[i]);
//     scheduleNotification(
//       id: 100 + i, // استخدم نطاق id مختلف لتجنب التعارض مع إشعارات تسجيل الدخول
//       title: 'تنبيه تسجيل الخروج',
//       body: 'حان وقت تسجيل الخروج، الرجاء تسجيل الخروج من التطبيق.',
//       scheduledDate: logoutTime,
//     );
//   }
// }
