extension DateTimeExtensions on DateTime {
  String get dayMonthYear => toString().split(' ')[0];
}
