import 'dart:ui';

extension LocaleExtensions on Locale {
  bool get isRtl {
    const rtlLanguages = ['ar', 'fa', 'he', 'ur'];
    return rtlLanguages.contains(languageCode.toLowerCase());
  }
}
