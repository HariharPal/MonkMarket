class CartItem {
  final String productId;
  final String title;
  final int priceInPaise;
  final int quantity;
  final String? imageUrl;
  final int lineTotalInPaise;

  const CartItem({
    required this.productId,
    required this.title,
    required this.priceInPaise,
    required this.quantity,
    this.imageUrl,
    required this.lineTotalInPaise,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      priceInPaise: (json['priceInPaise'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['imageUrl']?.toString(),
      lineTotalInPaise: (json['lineTotalInPaise'] as num?)?.toInt() ?? 0,
    );
  }
}

class Cart {
  final String cartId;
  final List<CartItem> items;
  final int totalInPaise;
  final String currency;

  const Cart({
    required this.cartId,
    required this.items,
    required this.totalInPaise,
    required this.currency,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsList =
        (json['items'] as List<dynamic>?)
            ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return Cart(
      cartId: json['cartId']?.toString() ?? '',
      items: itemsList,
      totalInPaise: (json['totalInPaise'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
    );
  }
}
