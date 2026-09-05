import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage.dart';
import './api_config.dart';
import './api_exception.dart';
import './auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_secureStorage));

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (obj) {
          assert(() {
            final msg = obj.toString();

            if (!msg.contains('Authorization') &&
                !msg.contains('password') &&
                !msg.contains('signature')) {
              // ignore: avoid_print
              print('[API] $msg');
            }

            return true;
          }());
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  ApiException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapBadResponse(e);

      default:
        return ApiException(
          statusCode: e.response?.statusCode,
          message:
              _extractServerMessage(e.response?.data) ??
              'An unexpected error occurred.',
          errorCode: _extractErrorCode(e.response?.data),
        );
    }
  }

  ApiException _mapBadResponse(DioException e) {
    final statusCode = e.response?.statusCode ?? 500;
    final data = e.response?.data;

    final errorCode = _extractErrorCode(data);
    final serverMessage = _extractServerMessage(data);

    return ApiException(
      statusCode: statusCode,
      message: serverMessage ?? _defaultMessageForStatus(statusCode),
      errorCode: errorCode,
    );
  }

  String? _extractErrorCode(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['errorCode']?.toString() ?? data['error']?.toString();
    }

    return null;
  }

  String? _extractServerMessage(dynamic data) {
    if (data is! Map) {
      return null;
    }

    final messages = data['messages'];

    if (messages is Map && messages.isNotEmpty) {
      final firstMessage = messages.values.first;

      if (firstMessage != null) {
        return firstMessage.toString();
      }
    }

    final message = data['message'];

    if (message != null) {
      return message.toString();
    }

    return null;
  }

  String _defaultMessageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';

      case 401:
        return 'Invalid email or password.';

      case 403:
        return "You don't have permission to perform this action.";

      case 404:
        return 'That item could not be found.';

      case 409:
        return 'This action conflicts with the current state.';

      case 410:
        return 'Your payment session has expired.';

      case 422:
        return 'The request could not be processed.';

      case 500:
      case 502:
      case 503:
        return 'Something went wrong. Please try again.';

      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
