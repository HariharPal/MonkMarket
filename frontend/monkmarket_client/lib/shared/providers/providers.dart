import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/local_storage.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/chat/repositories/agent_repository.dart';
import '../../features/catalog/repositories/catalog_repository.dart';
import '../../features/cart/repositories/cart_repository.dart';
import '../../features/payment/repositories/payment_repository.dart';
import '../../features/orders/repositories/order_repository.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
final localStorageProvider = Provider<LocalStorage>((ref) => LocalStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  return AgentRepository(ref.watch(apiClientProvider));
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(apiClientProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.watch(apiClientProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(apiClientProvider));
});
