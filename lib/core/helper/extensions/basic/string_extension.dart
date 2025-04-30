import 'package:intl/intl.dart';

extension StringExtension on String {
  String sanitize() {
    return replaceAll(RegExp(r'[^\x20-\x7E]'), '');
    // return replaceAll(RegExp(r'[^\x20-\x7Eء-ي]'), '');
  }

  String get capitalizeFirst =>
      isNotEmpty ? this[0].toUpperCase() + substring(1).toLowerCase() : "";

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
      return DateTime.parse(this!);
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
    final parsed = DateFormat("hh:mm a").tryParse(this) ??
        DateFormat("a hh:mm").parse(this);
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
  String formatNumber({int decimalPlaces = 2}) {
    double? number = double.tryParse(this);

    if (number == null || number.isNaN || number.isInfinite) {
      return "0"; // ضمان عدم إرجاع NaN أو قيم غير صحيحة
    }

    final formatter = NumberFormat("#,##0.${'0' * decimalPlaces}", "en_US");
    return formatter.format(number);
  }
}
