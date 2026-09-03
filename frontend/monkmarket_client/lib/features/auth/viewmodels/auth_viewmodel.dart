import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/providers/providers.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(const AuthState());

  Future<bool> restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.restoreSession();

      state = state.copyWith(user: user, isLoading: false);

      return user != null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());

      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.login(email, password);

      state = state.copyWith(user: user, isLoading: false, clearError: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('ApiException: ', ''),
      );

      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.register(name: name, email: email, password: password);

      state = state.copyWith(isLoading: false, clearError: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('ApiException: ', ''),
      );

      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();

    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});
