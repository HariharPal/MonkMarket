class AppConstants {
  AppConstants._();

  static const String appName = 'MonkMarket';
  static const String assistantName = 'Sahayak';

  static const String defaultCurrency = 'INR';
  static const String accessTokenKey = 'access_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
  static const String themeModeKey = 'theme_mode';

  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_TTytPp16m1heFY',
  );

  static const List<String> chatSuggestions = [
    'Find shoes',
    'Show me electronics',
    "What's in my cart?",
    'Help me checkout',
  ];
}
