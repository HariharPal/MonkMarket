// Models
class Product {
  final String id;
  final String title;
  final String description;
  final int priceInPaise;
  final String currency;
  final String category;
  final int stockQty;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.priceInPaise,
    required this.currency,
    required this.category,
    required this.stockQty,
    this.imageUrl,
  });

  bool get isInStock => stockQty > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priceInPaise: (json['priceInPaise'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      category: json['category']?.toString() ?? '',
      stockQty: (json['stockQty'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priceInPaise': priceInPaise,
    'currency': currency,
    'category': category,
    'stockQty': stockQty,
    'imageUrl': imageUrl,
  };
}

class ProductRecommendation {
  final Product product;
  final String reason;

  const ProductRecommendation({required this.product, required this.reason});

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      reason: json['reason']?.toString() ?? '',
    );
  }
}
