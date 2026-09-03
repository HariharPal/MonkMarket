import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/merchant_order.dart';
import '../repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ApiClient(baseUrl: AppConstants.commerceBaseUrl));
});

final merchantOrdersProvider = FutureProvider.autoDispose<List<MerchantOrder>>((
  ref,
) {
  return ref.read(orderRepositoryProvider).getOrders();
});

final merchantOrderDetailProvider = FutureProvider.autoDispose
    .family<MerchantOrder, String>((ref, orderId) {
      return ref.read(orderRepositoryProvider).getOrder(orderId);
    });
