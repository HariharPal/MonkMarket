class MerchantProduct {
  final String id;
  final String title;
  final String description;
  final int priceInPaise;
  final String currency;
  final String category;
  final int stockQty;
  final String? imageUrl;

  const MerchantProduct({
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

  factory MerchantProduct.fromMap(Map<String, dynamic> map) {
    return MerchantProduct(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      priceInPaise:
          (map['priceInPaise'] as num?)?.toInt() ??
          (map['price_in_paise'] as num?)?.toInt() ??
          0,
      currency: map['currency']?.toString() ?? 'INR',
      category: map['category']?.toString() ?? '',
      stockQty:
          (map['stockQty'] as num?)?.toInt() ??
          (map['stock_qty'] as num?)?.toInt() ??
          0,
      imageUrl: map['imageUrl']?.toString() ?? map['image_url']?.toString(),
    );
  }
}
