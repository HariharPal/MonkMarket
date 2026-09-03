import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../repositories/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final LoginResponse response;
  const LoginSuccess(this.response);
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _repository;

  LoginNotifier(this._repository) : super(const LoginInitial());

  Future<void> login({required String email, required String password}) async {
    state = const LoginLoading();
    try {
      final response = await _repository.login(
        LoginRequest(email: email.trim(), password: password),
      );
      state = LoginSuccess(response);
    } on AppException catch (e) {
      state = LoginError(e.message);
    } catch (_) {
      state = LoginError(AppException.server().message);
    }
  }

  void reset() => state = const LoginInitial();
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.read(authRepositoryProvider));
});
