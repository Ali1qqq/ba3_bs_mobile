import 'package:dio/dio.dart';

import '../interfaces/i_api_client.dart';

class DioClient<T> implements IAPiClient<T> {
  final Dio dio;

  DioClient(this.dio);

  @override
  Future<T> post(String url, {Map<String, String>? headers, Object? body}) async {
    final response = await dio.post(url, options: Options(headers: headers), data: body);

    if (response.statusCode == 200) {
      return response.data as T;
    } else {
      throw Exception('Dio Error: ${response.statusCode}');
    }
  }
}
