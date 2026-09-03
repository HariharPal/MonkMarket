import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/products/models/merchant_product.dart';
import '../../features/products/viewmodels/product_viewmodel.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(productListViewModelProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final state = ref.watch(productListViewModelProvider);

    final products = state.products;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            Text('Manage your catalog', style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: () {
              context.push('/products/create');
            },
            icon: const Icon(Icons.add_box_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: const InputDecoration(
                hintText: 'Search your products...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),

          Expanded(child: _buildBody(context, state, products, colors)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProductListState state,
    List<MerchantProduct> products,
    ColorScheme colors,
  ) {
    if (state.loading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(
              'Unable to load products',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                ref.read(productListViewModelProvider.notifier).loadProducts();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(productListViewModelProvider.notifier).loadProducts();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final product = products[index];

          return _ProductCard(
            product: product,
            onTap: () {
              context.push('/products/${product.id}');
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MerchantProduct product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.inventory_2_rounded,
                            color: colors.primary,
                          );
                        },
                      )
                    : Icon(
                        Icons.inventory_2_rounded,
                        color: colors.primary,
                        size: 30,
                      ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          '${product.currency} '
                          '${(product.priceInPaise / 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          '${product.stockQty} in stock',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: product.stockQty > 0
                                ? colors.onSurfaceVariant
                                : colors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
