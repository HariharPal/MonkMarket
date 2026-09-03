class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? errorCode;

  const ApiException({this.statusCode, required this.message, this.errorCode});

  factory ApiException.fromStatusCode(int statusCode, [String? errorCode]) {
    return ApiException(
      statusCode: statusCode,
      message: _messageForStatus(statusCode),
      errorCode: errorCode,
    );
  }

  static String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Your session expired. Please sign in again.';
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

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException extends ApiException {
  const NetworkException()
    : super(message: 'No internet connection. Please check your network.');
}

class TimeoutException extends ApiException {
  const TimeoutException()
    : super(message: 'Request timed out. Please try again.');
}
