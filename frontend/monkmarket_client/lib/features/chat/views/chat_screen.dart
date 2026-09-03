import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/recommendation_card.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../../catalog/views/home_screen.dart';
import '../../payment/viewmodels/payment_viewmodel.dart';
import '../models/agent_chat_response.dart';
import '../models/chat_message_ui_model.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _messageController.clear();
    await ref.read(chatViewModelProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _executeAction(AgentAction action) {
    switch (action.type) {
      case ActionType.viewProduct:
        break;
      case ActionType.addToCart:
        if (action.payload?.productId != null) {
          ref
              .read(cartViewModelProvider.notifier)
              .addItem(action.payload!.productId!);
        }
        break;
      case ActionType.proceedToPayment:
        final checkout = ref.read(chatViewModelProvider).currentCheckout;
        if (checkout != null) {
          ref.read(paymentViewModelProvider.notifier).setCheckout(checkout);
          context.go('/checkout');
        }
        break;
      case ActionType.confirmCheckout:
        _sendMessage('confirm checkout');
        break;
      case ActionType.rejectCheckout:
        _sendMessage('cancel checkout');
        break;
      case ActionType.viewOrder:
        if (action.payload?.orderId != null) {
          context.go('/orders/${action.payload!.orderId}');
        }
        break;
      case ActionType.continueShopping:
        context.go('/home');
        break;
      case ActionType.checkoutAgain:
        _sendMessage('checkout');
        break;
      case ActionType.retryPayment:
        _sendMessage('retry payment');
        break;
      case ActionType.cancelOrder:
        break;
      case ActionType.unknown:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen(chatViewModelProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.assistantName,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'AI Shopping Assistant',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New chat',
            onPressed: () {
              ref.read(chatViewModelProvider.notifier).startNewChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (chatState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.errorContainer,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    onPressed: () =>
                        ref.read(chatViewModelProvider.notifier).clearError(),
                    color: colorScheme.onErrorContainer,
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return _MessageWidget(
                  message: message,
                  onAction: _executeAction,
                  onAddToCart: (productId) => ref
                      .read(cartViewModelProvider.notifier)
                      .addItem(productId),
                  onViewProduct: (product) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ProductDetailsSheet(product: product),
                    );
                  },
                );
              },
            ),
          ),

          if (chatState.messages.length <= 1)
            _QuickSuggestions(onSuggestion: _sendMessage),

          _ChatInputBar(
            controller: _messageController,
            isSending: chatState.isSending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageWidget extends StatelessWidget {
  final ChatMessageUiModel message;
  final void Function(AgentAction) onAction;
  final void Function(String) onAddToCart;
  final void Function(dynamic) onViewProduct;

  const _MessageWidget({
    required this.message,
    required this.onAction,
    required this.onAddToCart,
    required this.onViewProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return const _TypingIndicator();
    }

    if (message.role == MessageRole.user) {
      return _UserBubble(text: message.text);
    }

    return _AssistantMessage(
      message: message,
      onAction: onAction,
      onAddToCart: onAddToCart,
      onViewProduct: onViewProduct,
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _AssistantMessage extends StatelessWidget {
  final ChatMessageUiModel message;
  final void Function(AgentAction) onAction;
  final void Function(String) onAddToCart;
  final void Function(dynamic) onViewProduct;

  const _AssistantMessage({
    required this.message,
    required this.onAction,
    required this.onAddToCart,
    required this.onViewProduct,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      colorScheme.surfaceContainerHighest ??
                      colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: colorScheme.outline, width: 1),
                ),
                child: Text(message.text, style: theme.textTheme.bodyMedium),
              ),

            if (message.responseType != null) ...[
              const SizedBox(height: 8),
              _buildStructuredContent(context, message),
            ],

            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                AppDateUtils.formatTime(message.timestamp),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuredContent(
    BuildContext context,
    ChatMessageUiModel message,
  ) {
    switch (message.responseType) {
      case ResponseType.productResults:
        return _ProductResultsWidget(
          products: message.products,
          recommendations: message.recommendations,
          onAddToCart: onAddToCart,
          onViewProduct: onViewProduct,
        );
      case ResponseType.cartUpdated:
        return _CartUpdatedCard(
          cart: message.cart,
          onAction: onAction,
          actions: message.actions,
        );
      case ResponseType.checkoutConfirmationRequired:
        return _CheckoutConfirmationCard(
          checkout: message.checkout,
          actions: message.actions,
          onAction: onAction,
        );
      case ResponseType.checkoutBlocked:
        return _CheckoutBlockedCard(
          guardrail: message.guardrail,
          actions: message.actions,
          onAction: onAction,
        );
      case ResponseType.paymentRequired:
        return _PaymentRequiredCard(
          checkout: message.checkout,
          actions: message.actions,
          onAction: onAction,
        );
      case ResponseType.paymentSuccess:
        return _PaymentSuccessCard(
          checkout: message.checkout,
          order: message.order,
          actions: message.actions,
          onAction: onAction,
        );
      case ResponseType.paymentFailed:
        return _PaymentFailedCard(actions: message.actions, onAction: onAction);
      case ResponseType.paymentExpired:
        return _PaymentExpiredCard(
          actions: message.actions,
          onAction: onAction,
        );
      case ResponseType.orderStatus:
        return _OrderListCard(
          orders: message.orders,
          onAction: onAction,
          actions: message.actions,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ProductResultsWidget extends StatelessWidget {
  final List products;
  final List recommendations;
  final void Function(String) onAddToCart;
  final void Function(dynamic) onViewProduct;

  const _ProductResultsWidget({
    required this.products,
    required this.recommendations,
    required this.onAddToCart,
    required this.onViewProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...products.map(
          (product) => ProductCard(
            product: product,
            onView: () => onViewProduct(product),
            onAdd: () => onAddToCart(product.id),
          ),
        ),
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'You might also like',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...recommendations.map(
            (rec) => RecommendationCard(
              product: rec.product,
              reason: rec.reason,
              onView: () => onViewProduct(rec.product),
              onAdd: () => onAddToCart(rec.product.id),
            ),
          ),
        ],
      ],
    );
  }
}

class _CartUpdatedCard extends StatelessWidget {
  final dynamic cart;
  final List actions;
  final void Function(AgentAction) onAction;

  const _CartUpdatedCard({
    required this.cart,
    required this.actions,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_cart_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Cart Updated', style: theme.textTheme.titleMedium),
              ],
            ),
            if (cart != null) ...[
              const SizedBox(height: 8),
              Text(
                '${cart.itemCount} product${cart.itemCount != 1 ? 's' : ''}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                'Total ${CurrencyUtils.formatPaise(cart.totalInPaise)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => GoRouter.of(context).go('/cart'),
                    child: const Text('View Cart'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => GoRouter.of(context).go('/chat'),
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutConfirmationCard extends StatelessWidget {
  final dynamic checkout;
  final List actions;
  final void Function(AgentAction) onAction;

  const _CheckoutConfirmationCard({
    required this.checkout,
    required this.actions,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmAction = actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.confirmCheckout,
      orElse: () => null,
    );
    final rejectAction = actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.rejectCheckout,
      orElse: () => null,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Review your order', style: theme.textTheme.titleMedium),
              ],
            ),
            const Divider(height: 24),
            if (checkout != null) ...[
              Text('Total:', style: theme.textTheme.bodyMedium),
              Text(
                CurrencyUtils.formatPaise(checkout.amountInPaise),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Are you ready to place this order?',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (rejectAction != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onAction(rejectAction),
                      child: const Text('Cancel'),
                    ),
                  ),
                if (rejectAction != null) const SizedBox(width: 8),
                if (confirmAction != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onAction(confirmAction),
                      child: const Text('Yes, place order'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBlockedCard extends StatelessWidget {
  final String? guardrail;
  final List actions;
  final void Function(AgentAction) onAction;

  const _CheckoutBlockedCard({
    required this.guardrail,
    required this.actions,
    required this.onAction,
  });

  String _guardrailMessage(String? code) {
    switch (code) {
      case 'AMOUNT_EXCEEDED':
        return 'The order amount exceeds the allowed limit.';
      case 'CATEGORY_NOT_ALLOWED':
        return 'This category is currently not allowed for checkout.';
      case 'AGENT_DISABLED':
        return 'AI checkout is currently unavailable.';
      case 'STOCK_UNAVAILABLE':
        return 'Some items are out of stock.';
      case 'HUMAN_CONFIRM_REQUIRED':
        return 'This order requires manual confirmation.';
      default:
        return 'Checkout is currently unavailable.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final continueAction = actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.continueShopping,
      orElse: () => null,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.block_rounded, color: colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Checkout unavailable',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _guardrailMessage(guardrail),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (continueAction != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onAction(continueAction),
                  child: const Text('Continue Shopping'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRequiredCard extends ConsumerStatefulWidget {
  final dynamic checkout;
  final List actions;
  final void Function(AgentAction) onAction;

  const _PaymentRequiredCard({
    required this.checkout,
    required this.actions,
    required this.onAction,
  });

  @override
  ConsumerState<_PaymentRequiredCard> createState() =>
      _PaymentRequiredCardState();
}

class _PaymentRequiredCardState extends ConsumerState<_PaymentRequiredCard>
    with SingleTickerProviderStateMixin {
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    if (widget.checkout?.expiresAt == null) return;
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    final remaining = widget.checkout?.timeUntilExpiry;
    setState(() => _remaining = remaining);
    if (remaining != null && remaining > Duration.zero) {
      Future.delayed(const Duration(seconds: 1), _tick);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final checkout = widget.checkout;

    final proceedAction = widget.actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.proceedToPayment,
      orElse: () => null,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Payment Required', style: theme.textTheme.titleMedium),
              ],
            ),
            const Divider(height: 24),
            if (checkout != null) ...[
              Text(
                CurrencyUtils.formatPaise(checkout.amountInPaise),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_remaining != null && _remaining! > Duration.zero) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires in ${AppDateUtils.formatCountdown(_remaining!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _remaining!.inMinutes < 2
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 16),
            if (proceedAction != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onAction(proceedAction),
                  icon: const Icon(Icons.lock_rounded, size: 18),
                  label: const Text('Proceed to Payment'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSuccessCard extends StatelessWidget {
  final dynamic checkout;
  final dynamic order;
  final List actions;
  final void Function(AgentAction) onAction;

  const _PaymentSuccessCard({
    required this.checkout,
    required this.order,
    required this.actions,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final viewOrderAction = actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.viewOrder,
      orElse: () => null,
    );
    final continueAction = actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.continueShopping,
      orElse: () => null,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Successful',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your order has been paid.',
              style: theme.textTheme.bodyMedium,
            ),
            if (order != null) ...[
              const SizedBox(height: 8),
              Text(
                'Order ID: #${order.shortId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (viewOrderAction != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onAction(viewOrderAction),
                      child: const Text('View Order'),
                    ),
                  ),
                if (viewOrderAction != null && continueAction != null)
                  const SizedBox(width: 8),
                if (continueAction != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onAction(continueAction),
                      child: const Text('Continue'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentFailedCard extends StatelessWidget {
  final List actions;
  final void Function(AgentAction) onAction;

  const _PaymentFailedCard({required this.actions, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final retryAction = actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.retryPayment,
      orElse: () => null,
    );
    final continueAction = actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.continueShopping,
      orElse: () => null,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Failed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your payment could not be completed.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (retryAction != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onAction(retryAction),
                      child: const Text('Retry Payment'),
                    ),
                  ),
                if (retryAction != null && continueAction != null)
                  const SizedBox(width: 8),
                if (continueAction != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onAction(continueAction),
                      child: const Text('Continue Shopping'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentExpiredCard extends StatelessWidget {
  final List actions;
  final void Function(AgentAction) onAction;

  const _PaymentExpiredCard({required this.actions, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final checkoutAgainAction = actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.checkoutAgain,
      orElse: () => null,
    );
    final continueAction = actions.cast<AgentAction?>().firstWhere(
      (a) => a?.type == ActionType.continueShopping,
      orElse: () => null,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hourglass_disabled_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Session Expired',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'The previous payment session is no longer valid.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (checkoutAgainAction != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onAction(checkoutAgainAction),
                      child: const Text('Checkout Again'),
                    ),
                  ),
                if (checkoutAgainAction != null && continueAction != null)
                  const SizedBox(width: 8),
                if (continueAction != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onAction(continueAction),
                      child: const Text('Continue Shopping'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderListCard extends StatelessWidget {
  final List orders;
  final List actions;
  final void Function(AgentAction) onAction;

  const _OrderListCard({
    required this.orders,
    required this.actions,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (orders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "You haven't placed any orders yet.",
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order History', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...orders.map((order) {
          final viewAction = actions.cast<AgentAction?>().firstWhere(
            (a) =>
                a?.type == ActionType.viewOrder &&
                a?.payload?.orderId == order.orderId,
            orElse: () => AgentAction(
              type: ActionType.viewOrder,
              label: 'View',
              payload: ActionPayload(orderId: order.orderId),
            ),
          );

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.shortId}',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.formatPaise(order.totalInPaise),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            _StatusChip(status: order.status),
                            const SizedBox(width: 8),
                            if (order.createdAt != null)
                              Text(
                                AppDateUtils.formatDate(order.createdAt!),
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => onAction(viewAction!),
                    child: const Text('View'),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PAID':
        color = Colors.green;
        break;
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'FAILED':
        color = Theme.of(context).colorScheme.error;
        break;
      case 'EXPIRED':
        color = Colors.grey;
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final offset = ((_controller.value * 3) - i).clamp(0.0, 1.0);
                final opacity = (1 - (offset - 0.5).abs() * 2).clamp(0.3, 1.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _QuickSuggestions extends StatelessWidget {
  final void Function(String) onSuggestion;
  const _QuickSuggestions({required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: AppConstants.chatSuggestions
            .map(
              (s) =>
                  ActionChip(label: Text(s), onPressed: () => onSuggestion(s)),
            )
            .toList(),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final void Function(String) onSend;

  const _ChatInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: colorScheme.outline, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Ask Sahayak anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: isSending ? null : onSend,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: isSending
                ? Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : IconButton.filled(
                    onPressed: () => onSend(controller.text),
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
