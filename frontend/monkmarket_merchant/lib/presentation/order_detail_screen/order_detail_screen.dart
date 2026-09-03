import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/orders/viewmodels/order_viewmodel.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({required this.orderId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final order = ref.watch(merchantOrderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton.icon(
            onPressed: () {
              ref.invalidate(merchantOrderDetailProvider(orderId));
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ),
        data: (order) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(order: order, colors: colors),

              const SizedBox(height: 22),

              Text(
                'Items',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              ...order.items.map(
                (item) => _ItemCard(
                  item: item,
                  currency: order.currency,
                  colors: colors,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Order Information',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              _InfoRow(label: 'Order ID', value: order.id, colors: colors),

              _InfoRow(
                label: 'Customer ID',
                value: order.userId,
                colors: colors,
              ),

              _InfoRow(label: 'Cart ID', value: order.cartId, colors: colors),

              _InfoRow(
                label: 'Order status',
                value: order.status.replaceAll('_', ' '),
                colors: colors,
              ),

              if (order.paymentStatus != null)
                _InfoRow(
                  label: 'Payment status',
                  value: order.paymentStatus!.replaceAll('_', ' '),
                  colors: colors,
                ),

              if (order.razorpayOrderId != null)
                _InfoRow(
                  label: 'Razorpay order',
                  value: order.razorpayOrderId!,
                  colors: colors,
                ),

              if (order.razorpayPaymentId != null)
                _InfoRow(
                  label: 'Razorpay payment',
                  value: order.razorpayPaymentId!,
                  colors: colors,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final dynamic order;
  final ColorScheme colors;

  const _SummaryCard({required this.order, required this.colors});

  @override
  Widget build(BuildContext context) {
    final amount = (order.totalAmountInPaise / 100).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${order.currency} $amount',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            order.status.replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final dynamic item;
  final String currency;
  final ColorScheme colors;

  const _ItemCard({
    required this.item,
    required this.currency,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final total = (item.totalPriceInPaise / 100).toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Icon(
                        Icons.inventory_2_rounded,
                        color: colors.primary,
                      );
                    },
                  )
                : Icon(Icons.inventory_2_rounded, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '$currency $total',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colors;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
