import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        AppConstants.loginPath,
        data: request.toMap(),
      );
      final data = response.data as Map<String, dynamic>;
      final loginResponse = LoginResponse.fromMap(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.accessTokenKey,
        loginResponse.accessToken,
      );
      if (loginResponse.refreshToken != null) {
        await prefs.setString(
          AppConstants.refreshTokenKey,
          loginResponse.refreshToken!,
        );
      }
      await prefs.setString(
        AppConstants.merchantIdKey,
        loginResponse.merchantId,
      );

      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw AppException.invalidCredentials();
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        throw AppException.network();
      } else {
        throw AppException.server();
      }
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _apiClient.post(
      AppConstants.registerPath,
      data: {'name': name, 'email': email, 'password': password, 'role': role},
    );
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(AppConstants.logoutPath);
    } catch (_) {
      // Best-effort — clear local state regardless
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.accessTokenKey);
      await prefs.remove(AppConstants.refreshTokenKey);
      await prefs.remove(AppConstants.merchantIdKey);
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.accessTokenKey);
  }
}
