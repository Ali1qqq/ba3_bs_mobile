import 'package:intl/intl.dart';

extension StringExtension on String {
  String sanitize() {
    return replaceAll(RegExp(r'[^\x20-\x7E]'), '');
    // return replaceAll(RegExp(r'[^\x20-\x7Eء-ي]'), '');
  }

  String get capitalizeFirst => isNotEmpty ? this[0].toUpperCase() + substring(1).toLowerCase() : "";

  int get toInt => int.tryParse(this) ?? 0;

  double get toDouble => double.tryParse(this) ?? 0.0;
}

extension NullableStringExtension on String? {
  int get toInt {
    if (this == null || this!.isEmpty) return 0;
    return int.tryParse(this!) ?? 0;
  }

  bool get isLocationInEmirates {
    if (this == null) return false;
    return this!.contains('United Arab Emirates');
  }

  bool get toBool {
    if (this == null || this!.isEmpty) return false;
    return this!.toLowerCase() == 'true';
  }

  DateTime get toDate {
    if (this == null || this!.isEmpty) return DateTime(1970, 1, 1);
    try {
      return DateTime.parse(this!).copyWith(hour: DateTime.now().hour, minute: DateTime.now().minute, second: DateTime.now().second);
    } catch (e) {
      return DateTime(1970, 1, 1);
    }
  }

  DateTime get toStartDate {
    if (this == null || this!.isEmpty) return DateTime(1970, 1, 1);
    try {
      return DateTime.parse(this!).copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );
    } catch (e) {
      return DateTime(1970, 1, 1);
    }
  }

  DateTime get toEndDate {
    if (this == null || this!.isEmpty) return DateTime(1970, 1, 1);
    try {
      return DateTime.parse(this!).copyWith(
        hour: 23,
        minute: 59,
        second: 59,
        millisecond: 999,
        microsecond: 999,
      );
    } catch (e) {
      return DateTime(1970, 1, 1);
    }
  }

  double get toDouble {
    if (this == null) return 0.0;

    return double.tryParse(this!) ?? 0.0;
  }

  String get orEmpty => this ?? "";
}

extension TimeParsing on String {
  DateTime toWorkingTime() {
    final now = DateTime.now();
    final parsed = DateFormat("hh:mm a").tryParse(this) ?? DateFormat("a hh:mm").parse(this);
    return DateTime(
      now.year,
      now.month,
      now.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );
  }
}

extension NumberFormatting on String {
  String formatNumber() {
    final number = double.tryParse(this);

    if (number == null || number.isNaN || number.isInfinite) {
      return "0.00"; // لو القيمة مش رقم
    }

    final formatter = NumberFormat("#,##0.00", "en");
    // "en" = 1,234,567.89
    // إذا بدك أرقام عربية غيّرها لـ "ar"

    return formatter.format(number);
  }
}