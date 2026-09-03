import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/catalog/models/product.dart';
import '../../core/utils/currency_utils.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onView;
  final VoidCallback? onAdd;
  final bool isAddingToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onView,
    this.onAdd,
    this.isAddingToCart = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: colorScheme.primaryContainer,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: colorScheme.onPrimaryContainer,
                      size: 40,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: colorScheme.primaryContainer,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: colorScheme.onPrimaryContainer,
                      size: 40,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: 48,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      CurrencyUtils.formatPaise(product.priceInPaise),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.isInStock
                      ? 'In stock (${product.stockQty})'
                      : 'Out of stock',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: product.isInStock
                        ? Colors.green.shade600
                        : colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onView,
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('View'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: product.isInStock && !isAddingToCart
                            ? onAdd
                            : null,
                        icon: isAddingToCart
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 16,
                              ),
                        label: Text(product.isInStock ? 'Add' : 'Out of stock'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
