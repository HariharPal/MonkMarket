import '../../cart/models/cart.dart';
import '../../catalog/models/product.dart';
import '../../checkout/models/checkout.dart';
import '../../orders/models/order.dart';
import './agent_chat_response.dart';

enum MessageRole { user, assistant, loading }

class ChatMessageUiModel {
  final String id;
  final MessageRole role;
  final String text;
  final ResponseType? responseType;
  final List<Product> products;
  final List<ProductRecommendation> recommendations;
  final Cart? cart;
  final Checkout? checkout;
  final Order? order;
  final List<Order> orders;
  final List<AgentAction> actions;
  final DateTime timestamp;
  final bool isLoading;
  final String? guardrail;

  const ChatMessageUiModel({
    required this.id,
    required this.role,
    required this.text,
    this.responseType,
    this.products = const [],
    this.recommendations = const [],
    this.cart,
    this.checkout,
    this.order,
    this.orders = const [],
    this.actions = const [],
    required this.timestamp,
    this.isLoading = false,
    this.guardrail,
  });

  factory ChatMessageUiModel.user(String text) {
    return ChatMessageUiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessageUiModel.loading() {
    return ChatMessageUiModel(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.loading,
      text: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  factory ChatMessageUiModel.fromResponse(AgentChatResponse response) {
    return ChatMessageUiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      text: response.response,
      responseType: response.type,
      products: response.products,
      recommendations: response.recommendations,
      cart: response.cart,
      checkout: response.checkout,
      order: response.order,
      orders: response.orders,
      actions: response.actions,
      timestamp: DateTime.now(),
      guardrail: response.meta?.guardrail,
    );
  }

  factory ChatMessageUiModel.welcome() {
    return ChatMessageUiModel(
      id: 'welcome',
      role: MessageRole.assistant,
      text:
          'Hello! I\'m Sahayak, your AI shopping assistant. What are you looking for today?',
      timestamp: DateTime.now(),
    );
  }
}
