import '../../catalog/models/product.dart';
import '../../cart/models/cart.dart';
import '../../checkout/models/checkout.dart';
import '../../orders/models/order.dart';

enum ResponseType {
  normal,
  productResults,
  cartUpdated,
  checkoutConfirmationRequired,
  checkoutBlocked,
  paymentRequired,
  paymentSuccess,
  paymentFailed,
  paymentExpired,
  orderStatus,
  unknown,
}

extension ResponseTypeExt on String {
  ResponseType toResponseType() {
    switch (toUpperCase()) {
      case 'NORMAL':
        return ResponseType.normal;
      case 'PRODUCT_RESULTS':
        return ResponseType.productResults;
      case 'CART_UPDATED':
        return ResponseType.cartUpdated;
      case 'CHECKOUT_CONFIRMATION_REQUIRED':
        return ResponseType.checkoutConfirmationRequired;
      case 'CHECKOUT_BLOCKED':
        return ResponseType.checkoutBlocked;
      case 'PAYMENT_REQUIRED':
        return ResponseType.paymentRequired;
      case 'PAYMENT_SUCCESS':
        return ResponseType.paymentSuccess;
      case 'PAYMENT_FAILED':
        return ResponseType.paymentFailed;
      case 'PAYMENT_EXPIRED':
        return ResponseType.paymentExpired;
      case 'ORDER_STATUS':
        return ResponseType.orderStatus;
      default:
        return ResponseType.unknown;
    }
  }
}

enum ActionType {
  viewProduct,
  addToCart,
  proceedToPayment,
  retryPayment,
  cancelOrder,
  viewOrder,
  checkoutAgain,
  continueShopping,
  confirmCheckout,
  rejectCheckout,
  unknown,
}

extension ActionTypeExt on String {
  ActionType toActionType() {
    switch (toUpperCase()) {
      case 'VIEW_PRODUCT':
        return ActionType.viewProduct;
      case 'ADD_TO_CART':
        return ActionType.addToCart;
      case 'PROCEED_TO_PAYMENT':
        return ActionType.proceedToPayment;
      case 'RETRY_PAYMENT':
        return ActionType.retryPayment;
      case 'CANCEL_ORDER':
        return ActionType.cancelOrder;
      case 'VIEW_ORDER':
        return ActionType.viewOrder;
      case 'CHECKOUT_AGAIN':
        return ActionType.checkoutAgain;
      case 'CONTINUE_SHOPPING':
        return ActionType.continueShopping;
      case 'CONFIRM_CHECKOUT':
        return ActionType.confirmCheckout;
      case 'REJECT_CHECKOUT':
        return ActionType.rejectCheckout;
      default:
        return ActionType.unknown;
    }
  }
}

class ActionPayload {
  final String? productId;
  final String? orderId;

  const ActionPayload({this.productId, this.orderId});

  factory ActionPayload.fromJson(Map<String, dynamic> json) {
    return ActionPayload(
      productId: json['productId']?.toString(),
      orderId: json['orderId']?.toString(),
    );
  }
}

class AgentAction {
  final ActionType type;
  final String label;
  final ActionPayload? payload;

  const AgentAction({required this.type, required this.label, this.payload});

  factory AgentAction.fromJson(Map<String, dynamic> json) {
    return AgentAction(
      type: (json['type']?.toString() ?? '').toActionType(),
      label: json['label']?.toString() ?? '',
      payload: json['payload'] != null
          ? ActionPayload.fromJson(json['payload'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AgentMeta {
  final String? timestamp;
  final bool requiresConfirmation;
  final String? guardrail;
  final String? errorCode;

  const AgentMeta({
    this.timestamp,
    this.requiresConfirmation = false,
    this.guardrail,
    this.errorCode,
  });

  factory AgentMeta.fromJson(Map<String, dynamic> json) {
    return AgentMeta(
      timestamp: json['timestamp']?.toString(),
      requiresConfirmation: json['requiresConfirmation'] as bool? ?? false,
      guardrail: json['guardrail']?.toString(),
      errorCode: json['errorCode']?.toString(),
    );
  }
}

class AgentChatResponse {
  final String sessionId;
  final ResponseType type;
  final String response;
  final List<Product> products;
  final List<ProductRecommendation> recommendations;
  final Cart? cart;
  final Checkout? checkout;
  final Order? order;
  final List<Order> orders;
  final List<AgentAction> actions;
  final AgentMeta? meta;

  const AgentChatResponse({
    required this.sessionId,
    required this.type,
    required this.response,
    this.products = const [],
    this.recommendations = const [],
    this.cart,
    this.checkout,
    this.order,
    this.orders = const [],
    this.actions = const [],
    this.meta,
  });

  factory AgentChatResponse.fromJson(Map<String, dynamic> json) {
    return AgentChatResponse(
      sessionId: json['sessionId']?.toString() ?? '',
      type: (json['type']?.toString() ?? 'NORMAL').toResponseType(),
      response: json['response']?.toString() ?? '',
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ProductRecommendation.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      cart: json['cart'] != null
          ? Cart.fromJson(json['cart'] as Map<String, dynamic>)
          : null,
      checkout: json['checkout'] != null
          ? Checkout.fromJson(json['checkout'] as Map<String, dynamic>)
          : null,
      order: json['order'] != null
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((e) => AgentAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: json['meta'] != null
          ? AgentMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}
