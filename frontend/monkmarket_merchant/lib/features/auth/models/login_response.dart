class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final String merchantId;
  final String email;
  final String name;
  final String role;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.merchantId,
    required this.email,
    required this.name,
    required this.role,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> map) {
    return LoginResponse(
      accessToken:
          map['accessToken'] as String? ?? map['access_token'] as String? ?? '',
      refreshToken:
          map['refreshToken'] as String? ?? map['refresh_token'] as String?,
      merchantId:
          map['merchantId'] as String? ??
          map['merchant_id'] as String? ??
          map['userId'] as String? ??
          map['user_id'] as String? ??
          '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? map['username'] as String? ?? 'Merchant',
      role: map['role'] as String? ?? map['roles'] as String? ?? 'MERCHANT',
    );
  }
}
