import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/orders/models/merchant_order.dart';
import '../../features/orders/viewmodels/order_viewmodel.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final orders = ref.watch(merchantOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            Text('Monitor customer orders', style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorState(
          onRetry: () {
            ref.invalidate(merchantOrdersProvider);
          },
        ),
        data: (allOrders) {
          final filtered = allOrders.where((order) {
            final query = _query.trim().toLowerCase();

            if (query.isEmpty) {
              return true;
            }

            return order.id.toLowerCase().contains(query) ||
                order.userId.toLowerCase().contains(query) ||
                order.items.any(
                  (item) => item.productName.toLowerCase().contains(query),
                );
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(merchantOrdersProvider);

              await ref.read(merchantOrdersProvider.future);
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search orders...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();

                                setState(() {
                                  _query = '';
                                });
                              },
                              icon: const Icon(Icons.clear_rounded),
                            ),
                    ),
                  ),
                ),

                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No orders found.'))
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final order = filtered[index];

                            return _OrderCard(
                              order: order,
                              colors: colors,
                              onTap: () {
                                context.push('/orders/${order.id}');
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final MerchantOrder order;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amount = (order.totalAmountInPaise / 100).toStringAsFixed(2);

    final status = order.status.replaceAll('_', ' ');

    final payment = order.paymentStatus?.replaceAll('_', ' ');

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${_shortId(order.id)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '${order.items.length} '
                          '${order.items.length == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '${order.currency} $amount',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              const Divider(),

              const SizedBox(height: 9),

              Row(
                children: [
                  _StatusChip(
                    label: status,
                    colors: colors,
                    positive:
                        order.status == 'PAID' || order.status == 'CONFIRMED',
                  ),

                  if (payment != null) ...[
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: 'Payment: $payment',
                      colors: colors,
                      positive: payment == 'PAID',
                    ),
                  ],

                  const Spacer(),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Customer: '
                  '${_shortId(order.userId)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _shortId(String id) {
    if (id.length <= 16) {
      return id;
    }

    return '${id.substring(0, 8)}...'
        '${id.substring(id.length - 6)}';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final ColorScheme colors;
  final bool positive;

  const _StatusChip({
    required this.label,
    required this.colors,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final bg = positive
        ? colors.secondaryContainer
        : colors.surfaceContainerHighest;

    final fg = positive ? colors.onSecondaryContainer : colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: colors.error),
          const SizedBox(height: 12),
          Text(
            'Unable to load orders',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
