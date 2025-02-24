extension DateFormatExtension on String {
  /// تحويل التاريخ من أي صيغة بين `day-month-year` و`year-month-day` إلى `year-month-day`
  String toYearMonthDayFormat() {
    // تقسيم النص إلى أجزاء بناءً على الفاصل "-"
    List<String> parts = split('-');

    // التحقق من وجود 3 أجزاء
    if (parts.length != 3) {
      throw FormatException('Invalid date format: $this');
    }

    // تحديد ما إذا كان النص في صيغة `day-month-year` أو `year-month-day`
    // نفترض أن السنة هي الجزء الأطول (4 أرقام)
    if (parts[0].length == 4) {
      // الصيغة الحالية: `year-month-day`
      return this; // لا حاجة للتغيير
    } else if (parts[2].length == 4) {
      // الصيغة الحالية: `day-month-year`
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      return '$year-$month-$day';
    } else {
      throw FormatException('Invalid date format: $this');
    }
  }
}


