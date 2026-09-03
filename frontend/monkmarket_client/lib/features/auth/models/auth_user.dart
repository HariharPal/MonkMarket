class AuthUser {
  final String userId;
  final String email;
  final String role;
  final String accessToken;

  const AuthUser({
    required this.userId,
    required this.email,
    required this.role,
    required this.accessToken,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json, String token) {
    return AuthUser(
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'USER',
      accessToken: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'role': role,
      'accessToken': accessToken,
    };
  }
}
class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
