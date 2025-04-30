import 'dart:convert';

import '../interfaces/i_api_client.dart';
import '../interfaces/i_translation_service.dart';

class GoogleTranslationService implements ITranslationService {
  final String baseUrl;
  final String apiKey;
  final IAPiClient client;

  GoogleTranslationService(
      {required this.baseUrl, required this.apiKey, required this.client});

  @override
  Future<String> getTranslation(String text) async {
    return await translateText(text, 'ar', 'en');
  }

  Future<String> translateText(
      String text, String fromLang, String toLang) async {
    final String url = '$baseUrl?key=$apiKey';

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': text,
          'source': fromLang,
          'target': toLang,
          'format': 'text'
        }),
      );

      return response['data']['translations'][0]['translatedText'];
    } catch (e) {
      rethrow;
    }
  }
}
