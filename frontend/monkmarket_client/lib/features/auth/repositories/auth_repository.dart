import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_user.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepository(this._apiClient, this._secureStorage);

  Future<AuthUser> login(String email, String password) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConfig.authBase}/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;

      if (data == null) {
        throw const ApiException(
          message: 'Login failed. Empty response from server.',
        );
      }

      final token = data['accessToken']?.toString() ?? '';

      if (token.isEmpty) {
        throw const ApiException(
          message: 'Login failed. No access token received.',
        );
      }

      final user = AuthUser.fromJson(data, token);

      if (user.userId.isEmpty) {
        throw const ApiException(
          message: 'Login failed. User ID was not returned.',
        );
      }

      await _secureStorage.saveAccessToken(token);
      await _secureStorage.saveUserId(user.userId);

      await _secureStorage.saveUsername(user.email);

      return user;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Login failed: ${e.toString()}');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<dynamic>(
        '${ApiConfig.authBase}/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw const ApiException(message: 'Registration failed.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Registration failed: ${e.toString()}');
    }
  }

  Future<AuthUser?> restoreSession() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final userId = await _secureStorage.getUserId();
      final username = await _secureStorage.getUsername();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        return null;
      }

      return AuthUser(
        userId: userId,
        email: username ?? '',
        role: 'USER',
        accessToken: token,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
  }
}
