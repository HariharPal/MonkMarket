import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../checkout/models/checkout.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  Future<Checkout> createPaymentOrder(String orderId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.paymentsOrders,
        data: {'orderId': orderId},
      );
      return Checkout.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.paymentsVerify,
        data: {
          'orderId': orderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
      return response.data ?? {};
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
