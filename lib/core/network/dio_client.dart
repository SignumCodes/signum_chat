import 'package:dio/dio.dart';
import '../constants/api_url.dart';
import 'dio_intercepter.dart';


class DeoClient {
  static late Dio dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        receiveDataWhenStatusError: true,
      ),
    );

    dio.interceptors.addAll([
      LogInterceptor(
        error: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
     DeoInterceptor(),
    ]);
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    bool isHeader = false,
    bool isLanguage = false,
  }) async {
    return await dio.get(
      url,
      queryParameters: query,
      options: Options(
        extra: {'header': isHeader, 'language': isLanguage},
      ),
    );
  }

  static Future<Response> postData({
    required String url,
    Map<dynamic, dynamic>? data,
    FormData? formData,
    bool isHeader = false,
    bool isAllow412 = false,
    bool isLanguage = false,
  }) async {
    return await dio.post(
      url,
      data: formData ?? data,
      options: Options(
          extra: {
            'header': isHeader,
          },
          validateStatus: (status) {
            return isAllow412 && status == 412
                ? true
                : status == 200
                ? true
                : false;
          }),
    );
  }

  static Future<Response> putData({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? query,
    String lang = 'ar',
    String? token,
  }) async {
    dio.options.headers = {
      'lang': lang,
      'Authorization': token ?? '',
      'Content-Type': 'application/json',
    };
    return await dio.put(
      url,
      queryParameters: query,
      data: data,
    );
  }
}
