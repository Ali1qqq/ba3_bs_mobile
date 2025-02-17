import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';

extension ArabicNumberParsing on String {
  /// محاولة تحويل النص إلى قيمة Double
  double? parseToDouble() {
    String englishNumbers = AppServiceUtils.replaceArabicNumbersWithEnglish(this);
    return double.tryParse(englishNumbers);
  }
}