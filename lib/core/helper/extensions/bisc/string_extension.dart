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
      return DateTime(1970, 1, 1); // قيمة افتراضية عند حدوث خطأ
    }
  }


  String get orEmpty => this ?? "";
}
