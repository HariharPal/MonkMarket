import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('[API] $obj'),
        ),
      );
    }

    _dio.interceptors.add(_AuthInterceptor());
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(String path, {dynamic data, Options? options}) {
    return _dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> patch<T>(String path, {dynamic data, Options? options}) {
    return _dio.patch<T>(path, data: data, options: options);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(AppConstants.accessTokenKey);

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      debugPrint(
        '[AUTH] token attached: '
        '${token != null && token.isNotEmpty}',
      );
    } catch (e) {
      debugPrint('[AUTH] token read failed: $e');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      debugPrint('[AUTH] 401 Unauthorized: ${err.requestOptions.path}');
    }

    if (err.response?.statusCode == 403) {
      debugPrint('[AUTH] 403 Forbidden: ${err.requestOptions.path}');
    }

    handler.next(err);
  }
}
