import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';
import '../../../shared/providers/providers.dart';

class OrderState {
  final List<Order> orders;
  final Order? selectedOrder;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.selectedOrder,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? selectedOrder,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      selectedOrder: clearSelected
          ? null
          : (selectedOrder ?? this.selectedOrder),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OrderViewModel extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderViewModel(this._repository) : super(const OrderState());

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await _repository.getMyOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  Future<void> loadOrder(String orderId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final order = await _repository.getOrder(orderId);
      state = state.copyWith(selectedOrder: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final orderViewModelProvider =
    StateNotifierProvider<OrderViewModel, OrderState>((ref) {
      return OrderViewModel(ref.watch(orderRepositoryProvider));
    });
