import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'failure.dart';

sealed class AppException implements Exception {
  const AppException();
}

class DioAppException extends AppException {
  final DioException error;

  const DioAppException(this.error);
}

class SocketAppException extends AppException {
  const SocketAppException();
}

class FirebaseAppException extends AppException {
  final FirebaseException error;

  const FirebaseAppException(this.error);
}

class FailureAppException extends AppException {
  final Failure failure;

  const FailureAppException(this.failure);
}

class UnknownAppException extends AppException {
  final dynamic error;

  const UnknownAppException(this.error);
}
