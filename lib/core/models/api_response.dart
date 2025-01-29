import 'package:dio/dio.dart';

class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;
  final DioException? error;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
    this.error,
  });


  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode,
    );
  }


  factory ApiResponse.error(DioException error, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      data: null,
      message: message,
      success: false,
      statusCode: statusCode,
      error: error,
    );
  }


  bool isSuccess() => success;

  bool isError() => !success;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode, data: $data)';
  }
}
