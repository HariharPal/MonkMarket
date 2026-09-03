import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_utils.dart';
import '../models/cart.dart';
import '../viewmodels/cart_viewmodel.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartViewModelProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (cartState.cart != null && cartState.cart!.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () =>
                  ref.read(cartViewModelProvider.notifier).loadCart(),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (cartState.isLoading && cartState.cart == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartState.error != null && cartState.cart == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(cartState.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(cartViewModelProvider.notifier).loadCart(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final cart = cartState.cart;
          if (cart == null || cart.items.isEmpty) {
            return _EmptyCart(onStartShopping: () => context.go('/home'));
          }

          return Column(
            children: [
              if (cartState.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: colorScheme.errorContainer,
                  child: Text(
                    cartState.error!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemTile(
                      item: item,
                      isLoading: cartState.loadingItems.contains(
                        item.productId,
                      ),
                      onRemove: () => ref
                          .read(cartViewModelProvider.notifier)
                          .removeItem(item.productId),
                      onDecrement: () => ref
                          .read(cartViewModelProvider.notifier)
                          .updateQuantity(item.productId, item.quantity - 1),
                      onIncrement: () => ref
                          .read(cartViewModelProvider.notifier)
                          .updateQuantity(item.productId, item.quantity + 1),
                    );
                  },
                ),
              ),
              _CartSummary(cart: cart, onCheckout: () => context.go('/chat')),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool isLoading;
  final VoidCallback onRemove;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CartItemTile({
    required this.item,
    required this.isLoading,
    required this.onRemove,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          _imagePlaceholder(colorScheme),
                    )
                  : _imagePlaceholder(colorScheme),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtils.formatPaise(item.priceInPaise),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quantity controls
                      if (isLoading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else ...[
                        _QtyButton(
                          icon: Icons.remove_rounded,
                          onTap: onDecrement,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${item.quantity}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        _QtyButton(icon: Icons.add_rounded, onTap: onIncrement),
                      ],
                      const Spacer(),
                      TextButton.icon(
                        onPressed: isLoading ? null : onRemove,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        label: Text(
                          'Remove',
                          style: TextStyle(color: colorScheme.error),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: ${CurrencyUtils.formatPaise(item.lineTotalInPaise)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 80,
      height: 80,
      color: colorScheme.primaryContainer,
      child: Icon(
        Icons.shopping_bag_outlined,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: colorScheme.primary),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final Cart cart;
  final VoidCallback onCheckout;

  const _CartSummary({required this.cart, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: colorScheme.outline)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: theme.textTheme.titleMedium),
              Text(
                CurrencyUtils.formatPaise(cart.totalInPaise),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Checkout with Sahayak'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onStartShopping;
  const _EmptyCart({required this.onStartShopping});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty.',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add some products to get started!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onStartShopping,
              icon: const Icon(Icons.storefront_rounded),
              label: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
