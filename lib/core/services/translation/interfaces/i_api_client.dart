abstract class IAPiClient<T> {
  Future<T> post(String url, {Map<String, String>? headers, Object? body});
}
