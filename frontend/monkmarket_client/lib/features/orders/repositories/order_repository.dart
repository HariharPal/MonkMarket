import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../models/order.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _apiClient.get<dynamic>(ApiConfig.ordersMy);

      final data = response.data;

      if (data is List) {
        return data
            .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Order> getOrder(String orderId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConfig.ordersCreate}/$orderId',
      );

      if (response.data == null) {
        throw ApiException(message: 'Order response was empty.');
      }

      return Order.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
