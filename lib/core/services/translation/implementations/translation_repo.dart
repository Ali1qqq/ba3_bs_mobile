import 'package:flutter/cupertino.dart';

import '../interfaces/i_translation_service.dart';

class TranslationRepository {
  final ITranslationService _dataSource;

  TranslationRepository(this._dataSource);

  Future<String> translateText(String text) async {
    if (_isArabic(text)) {
      try {
        return await _dataSource.getTranslation(text);
      } catch (e) {
        debugPrint('Translation error: $e');
        // Return original text as a fallback in case of translation failure
        return text;
      }
    } else {
      return text;
    }
  }

  bool _isArabic(String text) {
    return text.runes.any((c) => c >= 0x0600 && c <= 0x06FF);
  }
}
