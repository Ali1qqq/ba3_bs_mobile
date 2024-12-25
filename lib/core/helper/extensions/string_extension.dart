extension StringExtension on String {
  String get capitalizeFirst => this[0].toUpperCase() + substring(1).toLowerCase();

  int? get toInt => int.tryParse(this);

  double? get toDouble => double.tryParse(this);
}

extension NullableStringExtension on String? {
  int get toInt {
    if (this == null) return 0;

    if (this!.isEmpty) return 0;

    return int.parse(this!);
  }

  bool get isLocationInEmirates {
    if (this == null) return false;
    return this!.contains('United Arab Emirates');
  }

  bool get toBool {
    if (this == null) return false;
    return this == 'true';
  }

  DateTime? get toDate {
    if (this == null || this!.isEmpty) return null;
    try {
      return DateTime.parse(this!);
    } catch (e) {
      return null;
    }
  }
}
