extension ArabicNumberParsing on String {
  /// تحويل الأرقام العربية إلى أرقام إنجليزية
  String replaceArabicNumbersWithEnglish() {
    return replaceAllMapped(RegExp(r'[٠-٩]'), (Match match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x0660 + 0x0030);
    });
  }

  /// محاولة تحويل النص إلى قيمة Double
  double? parseToDouble() {
    String englishNumbers = replaceArabicNumbersWithEnglish();
    return double.tryParse(englishNumbers);
  }
}


