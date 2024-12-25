import 'dart:convert';

import 'package:http/http.dart';

import '../interfaces/i_api_client.dart';

class HttpClient<T> implements IAPiClient<T> {
  final Client client;

  HttpClient(this.client);

  @override
  Future<T> post(String url, {Map<String, String>? headers, Object? body}) async {
    final response = await client.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }
}
