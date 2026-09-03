import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../models/product.dart';

class CatalogRepository {
  final ApiClient _apiClient;

  CatalogRepository(this._apiClient);

  Future<List<Product>> search({
    String? query,
    String? category,
    int? maxPricePaise,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (query != null && query.trim().isNotEmpty) {
        queryParams['q'] = query.trim();
      }

      if (category != null && category.trim().isNotEmpty) {
        queryParams['category'] = category.trim();
      }

      if (maxPricePaise != null) {
        queryParams['maxPricePaise'] = maxPricePaise;
      }

      final response = await _apiClient.get<dynamic>(
        ApiConfig.catalogSearch,
        queryParameters: queryParams,
      );

      final data = response.data;

      if (data is List) {
        return data
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
