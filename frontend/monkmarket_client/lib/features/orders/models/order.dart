export '../../cart/models/cart.dart' show CartItem;

class OrderItem {
  final String productId;
  final String title;
  final int priceInPaise;
  final int quantity;
  final String? imageUrl;
  final int totalPriceInPaise;

  const OrderItem({
    required this.productId,
    required this.title,
    required this.priceInPaise,
    required this.quantity,
    this.imageUrl,
    required this.totalPriceInPaise,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId']?.toString() ?? '',
      title: json['productName']?.toString() ?? '',
      priceInPaise: (json['priceInPaise'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['imageUrl']?.toString(),
      totalPriceInPaise: (json['totalPriceInPaise'] as num?)?.toInt() ?? 0,
    );
  }
}

class Order {
  final String orderId;
  final String status;
  final List<OrderItem> items;
  final int totalInPaise;
  final String currency;
  final DateTime? createdAt;

  const Order({
    required this.orderId,
    required this.status,
    required this.items,
    required this.totalInPaise,
    required this.currency,
    this.createdAt,
  });

  String get shortId => orderId.length > 8 ? orderId.substring(0, 8) : orderId;

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;

    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {
        createdAt = null;
      }
    }

    final itemsList =
        (json['items'] as List<dynamic>?)
            ?.map(
              (e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [];

    return Order(
      orderId: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      items: itemsList,
      totalInPaise: (json['totalAmountInPaise'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      createdAt: createdAt,
    );
  }
}
