import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.uri.path;

    final isPublicAuthEndpoint =
        path == '/api/v1/auth/login' || path == '/api/v1/auth/register';

    if (!isPublicAuthEndpoint) {
      final token = await _secureStorage.getAccessToken();
      final userId = await _secureStorage.getUserId();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      if (userId != null && userId.isNotEmpty) {
        options.headers['X-User-Id'] = userId;
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
