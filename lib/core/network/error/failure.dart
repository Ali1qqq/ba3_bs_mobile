class Failure implements Exception {
  Failure(this.code, this.message);

  int code;
  String message;
}
