import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart.dart';
import '../repositories/cart_repository.dart';
import '../../../shared/providers/providers.dart';

class CartState {
  final Cart? cart;
  final bool isLoading;
  final String? error;
  final Set<String> loadingItems;

  const CartState({
    this.cart,
    this.isLoading = false,
    this.error,
    this.loadingItems = const {},
  });

  int get itemCount => cart?.itemCount ?? 0;

  CartState copyWith({
    Cart? cart,
    bool? isLoading,
    String? error,
    Set<String>? loadingItems,
    bool clearError = false,
    bool clearCart = false,
  }) {
    return CartState(
      cart: clearCart ? null : (cart ?? this.cart),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      loadingItems: loadingItems ?? this.loadingItems,
    );
  }
}

class CartViewModel extends StateNotifier<CartState> {
  final CartRepository _repository;

  CartViewModel(this._repository) : super(const CartState());

  Future<void> clearCart() async {
    final currentCart = state.cart;

    if (currentCart == null) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.clearCart(currentCart.cartId);

      state = state.copyWith(
        clearCart: true,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cart = await _repository.getCart();
      state = state.copyWith(cart: cart, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  Future<bool> addItem(String productId, {int quantity = 1}) async {
    final loading = {...state.loadingItems, productId};
    state = state.copyWith(loadingItems: loading, clearError: true);
    try {
      final cart = await _repository.addItem(productId, quantity);
      final updated = state.loadingItems.difference({productId});
      state = state.copyWith(cart: cart, loadingItems: updated);
      return true;
    } catch (e) {
      final updated = state.loadingItems.difference({productId});
      state = state.copyWith(
        loadingItems: updated,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
      return false;
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }
    final loading = {...state.loadingItems, productId};
    state = state.copyWith(loadingItems: loading, clearError: true);
    try {
      final cart = await _repository.updateQuantity(productId, quantity);
      final updated = state.loadingItems.difference({productId});
      state = state.copyWith(cart: cart, loadingItems: updated);
    } catch (e) {
      final updated = state.loadingItems.difference({productId});
      state = state.copyWith(
        loadingItems: updated,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  Future<void> removeItem(String productId) async {
    final loading = {...state.loadingItems, productId};
    state = state.copyWith(loadingItems: loading, clearError: true);
    try {
      final cart = await _repository.removeItem(productId);
      final updated = state.loadingItems.difference({productId});
      state = state.copyWith(cart: cart, loadingItems: updated);
    } catch (e) {
      final updated = state.loadingItems.difference({productId});
      state = state.copyWith(
        loadingItems: updated,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  void updateCartFromAgent(Cart cart) {
    state = state.copyWith(cart: cart);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final cartViewModelProvider = StateNotifierProvider<CartViewModel, CartState>((
  ref,
) {
  return CartViewModel(ref.watch(cartRepositoryProvider));
});
