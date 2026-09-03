import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _desktop = 'http://localhost:8080';
  static const String _androidEmulator = 'http://10.0.2.2:8080';
  static const String _androidPhysical = 'http://192.168.1.7:8080';

  static String get baseUrl {
    if (kIsWeb) return _desktop;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidPhysical;
    }
    return _desktop;
  }

  static const String authBase = '/api/v1/auth';
  static const String catalogBase = '/api/v1/catalog';
  static const String agentBase = '/api/v1/agent';
  static const String ordersBase = '/api/v1/orders';
  static const String cartBase = '/api/v1/cart';
  static const String paymentsBase = '/api/v1/payments';

  static const String agentChat = '/api/v1/agent/chat';
  static const String catalogSearch = '/api/v1/catalog/search';
  static const String cartGet = '/api/v1/cart';
  static const String cartItems = '/api/v1/cart/items';
  static const String ordersCreate = '/api/v1/orders';
  static const String ordersMy = '/api/v1/orders/my';
  static const String paymentsOrders = '/api/v1/payments/orders';
  static const String paymentsVerify = '/api/v1/payments/verify';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);
}
