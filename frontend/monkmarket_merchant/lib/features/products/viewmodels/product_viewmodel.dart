import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_monkmarket/core/constants/app_constants.dart';

import '../../../core/network/api_client.dart';
import '../models/merchant_product.dart';
import '../repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ApiClient(baseUrl: AppConstants.commerceBaseUrl));
});

class ProductListState {
  final bool loading;
  final List<MerchantProduct> products;
  final List<String> categories;
  final String? error;

  const ProductListState({
    this.loading = false,
    this.products = const [],
    this.categories = const [],
    this.error,
  });

  ProductListState copyWith({
    bool? loading,
    List<MerchantProduct>? products,
    List<String>? categories,
    String? error,
    bool clearError = false,
  }) {
    return ProductListState(
      loading: loading ?? this.loading,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ProductListViewModel extends StateNotifier<ProductListState> {
  final ProductRepository repository;

  ProductListViewModel(this.repository) : super(const ProductListState());

  Future<void> loadProducts({String query = '', String? category}) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final products = await repository.getAllProducts();

      final normalizedQuery = query.trim().toLowerCase();

      final filteredProducts = products.where((product) {
        final matchesQuery =
            normalizedQuery.isEmpty ||
            product.title.toLowerCase().contains(normalizedQuery) ||
            product.description.toLowerCase().contains(normalizedQuery) ||
            product.category.toLowerCase().contains(normalizedQuery);

        final matchesCategory =
            category == null ||
            category.trim().isEmpty ||
            product.category.toLowerCase() == category.trim().toLowerCase();

        return matchesQuery && matchesCategory;
      }).toList();

      state = state.copyWith(loading: false, products: filteredProducts);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadCategories() async {
    try {
      final categories = await repository.getCategories();

      state = state.copyWith(categories: categories);
    } catch (_) {}
  }
}

final productListViewModelProvider =
    StateNotifierProvider<ProductListViewModel, ProductListState>((ref) {
      return ProductListViewModel(ref.read(productRepositoryProvider));
    });

final productDetailProvider = FutureProvider.autoDispose
    .family<MerchantProduct, String>((ref, productId) {
      return ref.read(productRepositoryProvider).getProduct(productId);
    });
