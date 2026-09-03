import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../models/merchant_product.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<MerchantProduct>> getAllProducts() async {
    try {
      final response = await _apiClient.get(AppConstants.merchantProductsPath);

      final data = response.data;

      if (data is! List) {
        throw const FormatException('Invalid products response');
      }

      return data
          .whereType<Map>()
          .map(
            (item) => MerchantProduct.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<MerchantProduct> getProduct(String productId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.merchantProductsPath}/$productId',
      );

      final data = response.data;

      if (data is! Map) {
        throw const FormatException('Invalid product detail response');
      }

      return MerchantProduct.fromMap(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/api/v1/catalog/categories');

      final data = response.data;

      if (data is! List) {
        throw const FormatException('Invalid category response');
      }

      return data.map((e) => e.toString()).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppException _mapDioError(DioException error) {
    final status = error.response?.statusCode;

    if (status == 401) {
      return AppException.unauthorized();
    }

    if (status == 403) {
      return AppException.forbidden();
    }

    if (status == 404) {
      return AppException.notFound('Product');
    }

    if (status != null && status >= 500) {
      return AppException.server();
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return AppException.network();
    }

    return AppException.server();
  }

  Future<MerchantProduct> createProduct({
    required String title,
    required String description,
    required int priceInPaise,
    required String currency,
    required String category,
    required int stockQty,
    required String? imageUrl,
    required bool agentVisible,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.merchantProductsPath,
        data: {
          'title': title,
          'description': description,
          'priceInPaise': priceInPaise,
          'currency': currency,
          'category': category,
          'stockQty': stockQty,
          'imageUrl': imageUrl,
          'agentVisible': agentVisible,
        },
      );

      if (response.data is! Map) {
        throw const FormatException('Invalid create product response');
      }

      return MerchantProduct.fromMap(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<MerchantProduct> updateProduct({
    required String productId,
    required String title,
    required String description,
    required int priceInPaise,
    required String currency,
    required String category,
    required int stockQty,
    required String? imageUrl,
    required bool agentVisible,
  }) async {
    try {
      final response = await _apiClient.put(
        '${AppConstants.merchantProductsPath}/$productId',
        data: {
          'title': title,
          'description': description,
          'priceInPaise': priceInPaise,
          'currency': currency,
          'category': category,
          'stockQty': stockQty,
          'imageUrl': imageUrl,
          'agentVisible': agentVisible,
        },
      );

      if (response.data is! Map) {
        throw const FormatException('Invalid update product response');
      }

      return MerchantProduct.fromMap(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }
}
