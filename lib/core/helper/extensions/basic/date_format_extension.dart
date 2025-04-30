extension DateFormatExtension on String {
  String toYearMonthDayFormat() {
    List<String> parts = split('-');

    if (parts.length != 3) {
      throw FormatException('Invalid date format: $this');
    }

    if (parts[0].length == 4) {
      return this;
    } else if (parts[2].length == 4) {
      String day = (parts[0]).padLeft(2, "0");
      String month = (parts[1]).padLeft(2, "0");
      String year = (parts[2]);
      return '$year-$month-$day';
    } else {
      throw FormatException('Invalid date format: $this');
    }
  }

  String toYearMonthFormat() {
    List<String> parts = split('-');

    if (parts.length != 3) {
      throw FormatException('Invalid date format: $this');
    }

    if (parts[0].length == 4) {
      return this;
    } else if (parts[2].length == 4) {
      String month = (parts[1]).padLeft(2, "0");
      String year = (parts[2]);
      return '$year-$month';
    } else {
      throw FormatException('Invalid date format: $this');
    }
  }
}
