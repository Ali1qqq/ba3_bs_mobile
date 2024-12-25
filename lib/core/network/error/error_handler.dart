// ignore_for_file: constant_identifier_names
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../../constants/app_constants.dart';
import 'app_exception.dart';
import 'failure.dart';

class ErrorHandler {
  final Failure failure;

  ErrorHandler(exception) : failure = _handleException(mapErrorToException(exception));
}

AppException mapErrorToException(error) {
  if (error is DioException) return DioAppException(error);
  if (error is SocketException) return const SocketAppException();
  if (error is FirebaseException) return FirebaseAppException(error);
  if (error is Failure) return FailureAppException(error);
  return UnknownAppException(error);
}

// Handling exceptions using sealed classes
Failure _handleException(AppException exception) {
  switch (exception) {
    case DioAppException dioException:
      return _handleDioError(dioException.error);
    case SocketAppException _:
      return ResponseTypes.NO_INTERNET_CONNECTION.getFailure();
    case FirebaseAppException firebaseException:
      return _handleFirebaseError(firebaseException.error);
    case FailureAppException failureException:
      return failureException.failure;
    case UnknownAppException unknownException:
      return _handleDefaultError(unknownException.error);
  }
}

Failure _handleDioError(DioException error) {
  String? errorMessage;

  if (error.response?.data is Map) {
    errorMessage = error.response?.data['error']?['message'] as String?;
  }
  errorMessage ??= error.response?.statusMessage ?? 'Unknown Dio error';

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return ResponseTypes.CONNECT_TIMEOUT.getFailure(message: errorMessage);
    case DioExceptionType.sendTimeout:
      return ResponseTypes.SEND_TIMEOUT.getFailure(message: errorMessage);
    case DioExceptionType.receiveTimeout:
      return ResponseTypes.RECEIVE_TIMEOUT.getFailure(message: errorMessage);
    case DioExceptionType.badResponse:
      return ResponseTypes.UNKNOWN.getFailure(message: errorMessage);
    case DioExceptionType.cancel:
      return ResponseTypes.CANCEL.getFailure(message: errorMessage);
    case DioExceptionType.unknown:
    case DioExceptionType.connectionError:
      return ResponseTypes.NO_INTERNET_CONNECTION.getFailure(message: errorMessage);
    default:
      return ResponseTypes.UNKNOWN.getFailure(message: errorMessage);
  }
}

Failure _handleFirebaseError(FirebaseException error) {
  switch (error.code) {
    case 'permission-denied':
      return ResponseTypes.FORBIDDEN.getFailure(message: 'Permission denied.');
    case 'unavailable':
      return ResponseTypes.INTERNAL_SERVER_ERROR.getFailure(message: 'Service temporarily unavailable.');
    case 'deadline-exceeded':
      return ResponseTypes.CONNECT_TIMEOUT.getFailure(message: 'Operation timed out.');
    case 'not-found':
      return ResponseTypes.NOT_FOUND.getFailure(message: 'Requested resource not found.');
    default:
      return ResponseTypes.UNKNOWN.getFailure(message: 'Firebase error: ${error.message ?? 'Unknown error'}');
  }
}

Failure _handleDefaultError(dynamic error) {
  final message = error is String ? error : error.toString();
  return ResponseTypes.UNKNOWN.getFailure(message: message);
}

enum ResponseTypes {
  SUCCESS,
  NO_CONTENT,
  BAD_REQUEST,
  FORBIDDEN,
  UNAUTHORISED,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  CONNECT_TIMEOUT,
  CANCEL,
  RECEIVE_TIMEOUT,
  SEND_TIMEOUT,
  CACHE_ERROR,
  NO_INTERNET_CONNECTION,
  UNKNOWN
}

extension ResponseTypeExtension on ResponseTypes {
  Failure getFailure({String? message}) {
    switch (this) {
      case ResponseTypes.SUCCESS:
        return Failure(ResponseCode.SUCCESS, message ?? ResponseMessage.SUCCESS);
      case ResponseTypes.NO_CONTENT:
        return Failure(ResponseCode.NO_CONTENT, message ?? ResponseMessage.NO_CONTENT);
      case ResponseTypes.BAD_REQUEST:
        return Failure(ResponseCode.BAD_REQUEST, message ?? ResponseMessage.BAD_REQUEST);
      case ResponseTypes.FORBIDDEN:
        return Failure(ResponseCode.FORBIDDEN, message ?? ResponseMessage.FORBIDDEN);
      case ResponseTypes.UNAUTHORISED:
        return Failure(ResponseCode.UNAUTHORISED, message ?? ResponseMessage.UNAUTHORISED);
      case ResponseTypes.NOT_FOUND:
        return Failure(ResponseCode.NOT_FOUND, message ?? ResponseMessage.NOT_FOUND);
      case ResponseTypes.INTERNAL_SERVER_ERROR:
        return Failure(ResponseCode.INTERNAL_SERVER_ERROR, message ?? ResponseMessage.INTERNAL_SERVER_ERROR);
      case ResponseTypes.CONNECT_TIMEOUT:
        return Failure(ResponseCode.CONNECT_TIMEOUT, message ?? ResponseMessage.CONNECT_TIMEOUT);
      case ResponseTypes.CANCEL:
        return Failure(ResponseCode.CANCEL, message ?? ResponseMessage.CANCEL);
      case ResponseTypes.RECEIVE_TIMEOUT:
        return Failure(ResponseCode.RECEIVE_TIMEOUT, message ?? ResponseMessage.RECEIVE_TIMEOUT);
      case ResponseTypes.SEND_TIMEOUT:
        return Failure(ResponseCode.SEND_TIMEOUT, message ?? ResponseMessage.SEND_TIMEOUT);
      case ResponseTypes.CACHE_ERROR:
        return Failure(ResponseCode.CACHE_ERROR, message ?? ResponseMessage.CACHE_ERROR);
      case ResponseTypes.NO_INTERNET_CONNECTION:
        return Failure(ResponseCode.NO_INTERNET_CONNECTION, message ?? ResponseMessage.NO_INTERNET_CONNECTION);
      case ResponseTypes.UNKNOWN:
        return Failure(ResponseCode.UNKNOWN, message ?? ResponseMessage.UNKNOWN);
    }
  }
}

class ResponseCode {
  static const int SUCCESS = 200; // success with data
  static const int NO_CONTENT = 201; // success with no data (no content)
  static const int BAD_REQUEST = 400; // failure, API rejected request
  static const int UNAUTHORISED = 401; // failure, user is not authorised
  static const int FORBIDDEN = 403; //  failure, API rejected request
  static const int INTERNAL_SERVER_ERROR = 500; // failure, crash in server side
  static const int NOT_FOUND = 404; // failure, not found

  // local status code
  static const int CONNECT_TIMEOUT = -1;
  static const int CANCEL = -2;
  static const int RECEIVE_TIMEOUT = -3;
  static const int SEND_TIMEOUT = -4;
  static const int CACHE_ERROR = -5;
  static const int NO_INTERNET_CONNECTION = -6;
  static const int UNKNOWN = -7;
}

class ResponseMessage {
  static const String SUCCESS = AppConstants.success; // success with data
  static const String NO_CONTENT = AppConstants.success; // success with no data (no content)
  static const String BAD_REQUEST = AppConstants.badRequestError; // failure, API rejected request
  static const String UNAUTHORISED = AppConstants.unauthorizedError; // failure, user is not authorised
  static const String FORBIDDEN = AppConstants.forbiddenError; //  failure, API rejected request
  static const String INTERNAL_SERVER_ERROR = AppConstants.internalServerError; // failure, crash in server side
  static const String NOT_FOUND = AppConstants.notFoundError; // failure, crash in server side

  // local status code
  static const String CONNECT_TIMEOUT = AppConstants.timeoutError;
  static const String CANCEL = AppConstants.cancelError;
  static const String RECEIVE_TIMEOUT = AppConstants.timeoutError;
  static const String SEND_TIMEOUT = AppConstants.timeoutError;
  static const String CACHE_ERROR = AppConstants.cacheError;
  static const String NO_INTERNET_CONNECTION = AppConstants.noInternetError;
  static const String UNKNOWN = AppConstants.defaultError;
}

class ApiInternalStatus {
  static const int SUCCESS = 0;
  static const int FAILURE = 1;
}

extension ResponseCodesExtension on int? {
  Failure getFailure() {
    switch (this) {
      case ResponseCode.SUCCESS:
        return Failure(ResponseCode.SUCCESS, ResponseMessage.SUCCESS);
      case ResponseCode.NO_CONTENT:
        return Failure(ResponseCode.NO_CONTENT, ResponseMessage.NO_CONTENT);
      case ResponseCode.BAD_REQUEST:
        return Failure(ResponseCode.BAD_REQUEST, ResponseMessage.BAD_REQUEST);
      case ResponseCode.FORBIDDEN:
        return Failure(ResponseCode.FORBIDDEN, ResponseMessage.FORBIDDEN);
      case ResponseCode.UNAUTHORISED:
        return Failure(ResponseCode.UNAUTHORISED, ResponseMessage.UNAUTHORISED);
      case ResponseCode.NOT_FOUND:
        return Failure(ResponseCode.NOT_FOUND, ResponseMessage.NOT_FOUND);
      case ResponseCode.INTERNAL_SERVER_ERROR:
        return Failure(ResponseCode.INTERNAL_SERVER_ERROR, ResponseMessage.INTERNAL_SERVER_ERROR);
      case ResponseCode.CONNECT_TIMEOUT:
        return Failure(ResponseCode.CONNECT_TIMEOUT, ResponseMessage.CONNECT_TIMEOUT);
      case ResponseCode.CANCEL:
        return Failure(ResponseCode.CANCEL, ResponseMessage.CANCEL);
      case ResponseCode.RECEIVE_TIMEOUT:
        return Failure(ResponseCode.RECEIVE_TIMEOUT, ResponseMessage.RECEIVE_TIMEOUT);
      case ResponseCode.SEND_TIMEOUT:
        return Failure(ResponseCode.SEND_TIMEOUT, ResponseMessage.SEND_TIMEOUT);
      case ResponseCode.CACHE_ERROR:
        return Failure(ResponseCode.CACHE_ERROR, ResponseMessage.CACHE_ERROR);
      case ResponseCode.NO_INTERNET_CONNECTION:
        return Failure(ResponseCode.NO_INTERNET_CONNECTION, ResponseMessage.NO_INTERNET_CONNECTION);
      case ResponseCode.UNKNOWN:
        return Failure(ResponseCode.UNKNOWN, ResponseMessage.UNKNOWN);
      default:
        return Failure(ResponseCode.UNKNOWN, ResponseMessage.UNKNOWN);
    }
  }
}
