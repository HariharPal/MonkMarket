class AppConstants {
  AppConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.7:8080',
  );

  static const String commerceBaseUrl = String.fromEnvironment(
    'COMMERCE_API_BASE_URL',
    defaultValue: 'http://192.168.1.7:8082',
  );

  static const String loginPath = '/api/v1/auth/login';
  static const String logoutPath = '/api/v1/auth/logout';
  static const String refreshTokenPath = '/api/v1/auth/refresh';

  static const String merchantProfilePath = '/api/v1/merchant/profile';
  static const String merchantDashboardPath = '/api/v1/merchant/dashboard';
  static const String registerPath = '/api/v1/auth/register';
  static const String merchantRevenueAnalyticsPath =
      '/api/v1/merchant/analytics/revenue';
  static const String merchantProductsPath = '/api/v1/catalog/products';
  static const String merchantOrdersPath = '/api/v1/merchant/orders';
  static const String merchantPaymentsPath = '/api/v1/merchant/payments';
  static const String merchantConversationsPath =
      '/api/v1/merchant/conversations';
  static const String merchantAuditPath = '/api/v1/merchant/audit';
  static const String merchantAgentStatusPath = '/api/v1/merchant/agent/status';
  static const String merchantAgentPausePath = '/api/v1/merchant/agent/pause';
  static const String merchantAgentResumePath = '/api/v1/merchant/agent/resume';
  static const String merchantPolicyPath = '/api/v1/merchant/policy';

  static const String accessTokenKey = 'merchant_access_token';
  static const String refreshTokenKey = 'merchant_refresh_token';
  static const String merchantIdKey = 'merchant_id';

  static const int defaultPageSize = 20;
  static const int defaultChartDays = 14;
}
