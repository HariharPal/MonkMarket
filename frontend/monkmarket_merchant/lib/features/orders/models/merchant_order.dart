class MerchantOrderItem {
  final String id;
  final String productId;
  final String productName;
  final int priceInPaise;
  final int quantity;
  final int totalPriceInPaise;
  final String? imageUrl;

  const MerchantOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.priceInPaise,
    required this.quantity,
    required this.totalPriceInPaise,
    this.imageUrl,
  });

  factory MerchantOrderItem.fromMap(Map<String, dynamic> map) {
    return MerchantOrderItem(
      id: map['id']?.toString() ?? '',
      productId:
          map['productId']?.toString() ?? map['product_id']?.toString() ?? '',
      productName:
          map['productName']?.toString() ??
          map['product_name']?.toString() ??
          '',
      priceInPaise:
          (map['priceInPaise'] as num?)?.toInt() ??
          (map['price_in_paise'] as num?)?.toInt() ??
          0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      totalPriceInPaise:
          (map['totalPriceInPaise'] as num?)?.toInt() ??
          (map['total_price_in_paise'] as num?)?.toInt() ??
          0,
      imageUrl: map['imageUrl']?.toString() ?? map['image_url']?.toString(),
    );
  }
}

class MerchantOrder {
  final String id;
  final String userId;
  final String cartId;
  final int totalAmountInPaise;
  final String currency;
  final String status;
  final String? paymentStatus;
  final String? paymentId;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final List<MerchantOrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MerchantOrder({
    required this.id,
    required this.userId,
    required this.cartId,
    required this.totalAmountInPaise,
    required this.currency,
    required this.status,
    required this.items,
    this.paymentStatus,
    this.paymentId,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.createdAt,
    this.updatedAt,
  });

  factory MerchantOrder.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List? ?? const [];

    return MerchantOrder(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? map['user_id']?.toString() ?? '',
      cartId: map['cartId']?.toString() ?? map['cart_id']?.toString() ?? '',
      totalAmountInPaise:
          (map['totalAmountInPaise'] as num?)?.toInt() ??
          (map['total_amount_in_paise'] as num?)?.toInt() ??
          0,
      currency: map['currency']?.toString() ?? 'INR',
      status: map['status']?.toString() ?? 'UNKNOWN',
      paymentStatus:
          map['paymentStatus']?.toString() ?? map['payment_status']?.toString(),
      paymentId: map['paymentId']?.toString() ?? map['payment_id']?.toString(),
      razorpayOrderId:
          map['razorpayOrderId']?.toString() ??
          map['razorpay_order_id']?.toString(),
      razorpayPaymentId:
          map['razorpayPaymentId']?.toString() ??
          map['razorpay_payment_id']?.toString(),
      items: rawItems
          .whereType<Map>()
          .map(
            (item) =>
                MerchantOrderItem.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}
