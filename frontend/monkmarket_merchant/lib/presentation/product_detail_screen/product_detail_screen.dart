import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/products/viewmodels/product_viewmodel.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({required this.productId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final product = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            tooltip: 'Edit product',
            onPressed: () {
              context.push('/products/$productId/edit');
            },
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton.icon(
            onPressed: () {
              ref.invalidate(productDetailProvider(productId));
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ),
        data: (product) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    product.imageUrl!,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _ImagePlaceholder(colors: colors);
                    },
                  ),
                )
              else
                _ImagePlaceholder(colors: colors),

              const SizedBox(height: 22),

              Text(
                product.title,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  _StatusChip(
                    text: product.category,
                    background: colors.primaryContainer,
                    foreground: colors.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    text: product.stockQty > 0 ? 'IN STOCK' : 'OUT OF STOCK',
                    background: product.stockQty > 0
                        ? colors.secondaryContainer
                        : colors.errorContainer,
                    foreground: product.stockQty > 0
                        ? colors.onSecondaryContainer
                        : colors.onErrorContainer,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                '${product.currency} '
                '${(product.priceInPaise / 100).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),

              const SizedBox(height: 20),

              _InfoCard(
                label: 'Stock',
                value: '${product.stockQty} units',
                colors: colors,
              ),

              _InfoCard(
                label: 'Category',
                value: product.category,
                colors: colors,
              ),

              _InfoCard(label: 'Product ID', value: product.id, colors: colors),

              const SizedBox(height: 10),

              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                product.description.trim().isEmpty
                    ? 'No description available.'
                    : product.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 28),

              FilledButton.icon(
                onPressed: () {
                  context.push('/products/$productId/edit');
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit Product'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final ColorScheme colors;

  const _ImagePlaceholder({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.inventory_2_rounded, size: 70, color: colors.primary),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _StatusChip({
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colors;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
