import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.userIdKey);
  }

  Future<void> saveUsername(String username) async {
    await _storage.write(key: AppConstants.usernameKey, value: username);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: AppConstants.usernameKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
