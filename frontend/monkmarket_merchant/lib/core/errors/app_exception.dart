class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException({required this.message, this.statusCode, this.code});

  factory AppException.network() => const AppException(
    message: 'Unable to reach the server. Please check your connection.',
    code: 'NETWORK_ERROR',
  );

  factory AppException.unauthorized() => const AppException(
    message: 'Your session has expired. Please sign in again.',
    statusCode: 401,
    code: 'UNAUTHORIZED',
  );

  factory AppException.forbidden() => const AppException(
    message: 'You do not have permission to perform this action.',
    statusCode: 403,
    code: 'FORBIDDEN',
  );

  factory AppException.notFound(String resource) => AppException(
    message: '$resource not found.',
    statusCode: 404,
    code: 'NOT_FOUND',
  );

  factory AppException.server() => const AppException(
    message: 'A server error occurred. Please try again.',
    statusCode: 500,
    code: 'SERVER_ERROR',
  );

  factory AppException.invalidCredentials() => const AppException(
    message: 'Invalid credentials — use the demo accounts below to sign in.',
    statusCode: 401,
    code: 'INVALID_CREDENTIALS',
  );

  @override
  String toString() => 'AppException($code): $message';
}
