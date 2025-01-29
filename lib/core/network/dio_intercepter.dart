import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'network_exception.dart';




/// Interceptor for the app
class DeoInterceptor extends Interceptor {
  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    log(options.headers.toString());
    if (options.extra.containsKey('header')) {
      options.headers.addAll(
          {'VAuthorization': await getToken(), 'Accept': 'application/json'});
    }
    if (options.extra.containsKey('language')) {
      options.headers.addAll({'Accept-Language': await getApplicationLanguage()});
    }
    return handler.next(options);
  }

  getToken() async {
    String? accessToken = "Bearer getTokenFromLocal";
    // String? accessToken = "Bearer ";

    if (kDebugMode) {
      print("Authorization $accessToken");
    }
    return accessToken;
  }

  getApplicationLanguage() async {
    String? appLanguage ="";
    // SharedPreferenceUtil.getString(userSelectedAppLanguageKey).isNotEmpty
    //     ? SharedPreferenceUtil.getString(userSelectedAppLanguageKey)
    //     : 'en';
    // //
    // if (kDebugMode) {
    //   print("appLanguage $appLanguage");
    // }
    return appLanguage;
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is a timeout error
    if (err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      // Throw a custom exception for timeout errors
      return handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: ServerConnectionException(
            'Couldn\'t connect with server. Please try again.'),
      ));
    }

    // Check if the error is regarding no internet connection.
    if (err.type == DioExceptionType.unknown && err.error is SocketException) {
      // No internet connection
      return handler.reject(DioError(
        requestOptions: err.requestOptions,
        error: NoInternetException(),
      ));
    }

    // Handle response errors (like 401, 500, etc.)
    if (err.type == DioExceptionType.values) {
      if (err.response?.statusCode == 401) {
        // AppUtils.instance.logout('Unauthorized access.');
        return handler.next(err); // Continue with the normal flow
      } else if (err.response?.statusCode == 500) {
        //  toast(error.message, colorPrimary, Colors.white);
      }
    }

    // Handle token expiry or authorization error
    if (err.type == DioExceptionType.unknown &&
        (err.message == 'TokenExpired' ||
            err.message == 'Authorization error')) {
      // AppUtils.instance.logout(err.message);
      return handler.next(err);
    }

    // Handle other response errors and custom network exceptions
    if (err.type == DioExceptionType.values && err.response != null) {
      NetworkException networkException = _getErrorObject(
          err.response!, err.requestOptions) ??
          NetworkException(
              err.requestOptions, 'Something went wrong, please try again!');
      return handler.reject(DioError(
        requestOptions: err.requestOptions,
        error: networkException,
      ));
    }

    // If none of the above conditions matched, pass the error to the next handler
    return handler.next(err);
  }

  /// Parses the response to get the error object if any
  /// from the API response based on status code.
  NetworkException? _getErrorObject(
      Response response, RequestOptions requestOptions) {
    final responseData = response.data;
    if (responseData != null && responseData is Map) {
      if (responseData.containsKey('status')) {
        // final status = responseData['status'];
        // if (!status) {
        // final errorsMap = responseData['errors'];
        /*if (errorsMap != null && errorsMap is Map) {
            Map<String, dynamic> map = errorsMap as Map<String, dynamic>;
            if (map.isNotEmpty) {
              final key = map.keys.toList()[0];
              return NetworkException(
                requestOptions,
                map[key] ?? 'Something went wrong, please try again!',
                code: response.statusCode ?? 0,
              );
            }
          }*/
        return NetworkException(
          requestOptions,
          responseData['message'] ?? 'Something went wrong, please try again!',
          code: response.statusCode ?? 0,
        );
        // }
      }
    }

    return FetchDataException(
        'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
  }


}
