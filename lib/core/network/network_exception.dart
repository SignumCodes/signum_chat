import 'package:dio/dio.dart';

/// Represents exception related to network
class NetworkException implements DioException {
  final String _message;
  final int code;

  @override
  final RequestOptions requestOptions;

  @override
  final Response? response;

  @override
  final DioExceptionType type;

  @override
  final Object? error;

  @override
  final StackTrace stackTrace;

  NetworkException(
      this.requestOptions,
      this._message, {
        this.code = -1,
        this.response,
        this.type = DioExceptionType.unknown,
        this.error,
        StackTrace? stackTrace,
      }) : stackTrace = stackTrace ?? StackTrace.empty;

  @override
  String get message => _message;

  @override
  String toString() => 'NetworkException: $message (code: $code, type: $type)';

  @override
  DioException copyWith({
    RequestOptions? requestOptions,
    Response? response,
    DioExceptionType? type,
    Object? error,
    StackTrace? stackTrace,
    String? message,
  }) {
    return NetworkException(
      requestOptions ?? this.requestOptions,
      message ?? this._message,
      code: code,
      response: response ?? this.response,
      type: type ?? this.type,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

/// Represents there's no internet connection
class NoInternetException extends NetworkException {
  NoInternetException([String? message, String? path])
      : super(
    RequestOptions(path: path ?? ''),
    message ?? 'No internet connection found!',
    type: DioExceptionType.connectionError,
  );
}

/// Represents error in communicating with server
class ServerConnectionException extends NetworkException {
  ServerConnectionException([String? message, String? path])
      : super(
    RequestOptions(path: path ?? ''),
    message ?? 'Failed to connect with server, please try again later',
    type: DioExceptionType.connectionError,
  );
}

/// Represents error during data fetching
class FetchDataException extends NetworkException {
  FetchDataException([String? message, String? path])
      : super(
    RequestOptions(path: path ?? ''),
    "Error During Communication: ${message ?? 'Unknown error'}",
  );
}

/// Represents bad request from the client
class BadRequestException extends NetworkException {
  BadRequestException([String? message, String? path])
      : super(
    RequestOptions(path: path ?? ''),
    "Invalid Request: ${message ?? 'Unknown error'}",
    type: DioExceptionType.badResponse,
  );
}

/// Represents unauthorized access
class UnauthorisedException extends NetworkException {
  UnauthorisedException([String? message, String? path])
      : super(
    RequestOptions(path: path ?? ''),
    "Unauthorized: ${message ?? 'Access denied'}",
    type: DioExceptionType.badResponse,
  );
}

/// Represents invalid input provided by the user
class InvalidInputException extends NetworkException {
  InvalidInputException([String? message, String? path])
      : super(
    RequestOptions(path: path ?? ''),
    "Invalid Input: ${message ?? 'Invalid data'}",
    type: DioExceptionType.unknown,
  );
}
