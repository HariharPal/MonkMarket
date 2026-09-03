import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/merchant_order.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<List<MerchantOrder>> getOrders() async {
    try {
      final response = await _apiClient.get(AppConstants.merchantOrdersPath);

      final data = response.data;

      if (data is! List) {
        throw const FormatException('Invalid orders response');
      }

      return data
          .whereType<Map>()
          .map((item) => MerchantOrder.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<MerchantOrder> getOrder(String orderId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.merchantOrdersPath}/$orderId',
      );

      if (response.data is! Map) {
        throw const FormatException('Invalid order detail response');
      }

      return MerchantOrder.fromMap(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Object _mapError(DioException error) {
    final status = error.response?.statusCode;

    if (status == 401) {
      return Exception('Unauthorized');
    }

    if (status == 403) {
      return Exception('Access denied');
    }

    if (status == 404) {
      return Exception('Order not found');
    }

    if (status != null && status >= 500) {
      return Exception('Commerce service error');
    }

    return Exception('Unable to load orders');
  }
}
