import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../models/cart.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository(this._apiClient);

  Future<Cart> getCart() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.cartGet,
      );
      return Cart.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Cart> addItem(String productId, int quantity) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConfig.cartBase}/items',
        data: {'productId': productId, 'quantity': quantity},
      );
      return Cart.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Cart> updateQuantity(String productId, int quantity) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConfig.cartBase}/items/$productId',
        data: {'quantity': quantity},
      );
      return Cart.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Cart> removeItem(String productId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConfig.cartItems}/$productId',
      );
      return Cart.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> clearCart(String cartId) async {
    try {
      await _apiClient.delete<dynamic>('${ApiConfig.cartBase}/$cartId');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
