import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monkmarket_client/core/network/api_config.dart';
import 'package:monkmarket_client/core/network/api_exception.dart';
import '../../catalog/models/product.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/providers/providers.dart';
import '../../../core/utils/currency_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  List<Product> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search({String? query, String? category}) async {
    if ((query == null || query.trim().isEmpty) &&
        (category == null || category.trim().isEmpty)) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final repo = ref.read(catalogRepositoryProvider);

      final results = await repo.search(
        query: query?.trim(),
        category: category?.trim(),
      );

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _hasSearched = true;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.shopping_bag_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'MonkMarket',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            tooltip: 'Ask Sahayak',
            onPressed: () => context.go('/chat'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _hasSearched = false;
                            });
                          },
                        )
                      : null,
                ),
                onSubmitted: (value) => _search(query: value),
                onChanged: (v) => setState(() {}),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),

          if (_isSearching)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_hasSearched) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  '${_searchResults.length} results',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            if (_searchResults.isEmpty)
              SliverToBoxAdapter(
                child: _EmptySearchState(
                  onAskSahayak: () => context.go('/chat'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = _searchResults[index];
                    return _SearchProductCard(product: product);
                  }, childCount: _searchResults.length),
                ),
              ),
          ] else ...[
            // Hero section
            SliverToBoxAdapter(
              child: _HeroSection(onAskSahayak: () => context.go('/chat')),
            ),
            // Categories
            SliverToBoxAdapter(
              child: _CategoriesSection(
                onCategoryTap: (category) {
                  _searchController.text = category;
                  _search(category: category);
                },
                onSearchTap: (query) {
                  _searchController.text = query;
                  _search(query: query);
                },
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _SearchProductCard extends ConsumerWidget {
  final Product product;
  const _SearchProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartVM = ref.read(cartViewModelProvider.notifier);
    final cartState = ref.watch(cartViewModelProvider);
    final isAdding = cartState.loadingItems.contains(product.id);

    return ProductCard(
      product: product,
      isAddingToCart: isAdding,
      onView: () => _showProductDetails(context, product),
      onAdd: () => cartVM.addItem(product.id),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailsSheet(product: product),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final VoidCallback onAskSahayak;
  const _HeroSection({required this.onAskSahayak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop smarter\nwith Sahayak',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your AI-powered shopping assistant',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(217),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAskSahayak,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colorScheme.primary,
            ),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Ask Sahayak'),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final void Function(String) onCategoryTap;
  final void Function(String) onSearchTap;

  const _CategoriesSection({
    required this.onCategoryTap,
    required this.onSearchTap,
  });

  static const _categories = [
    ('👟', 'SHOES'),
    ('👕', 'CLOTHING'),
    ('🎧', 'ELECTRONICS'),
    ('🎒', 'ACCESSORIES'),
    ('🏠', 'HOME'),
    ('📚', 'BOOKS'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text('Browse Categories', style: theme.textTheme.titleLarge),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final (emoji, label) = _categories[index];
              return GestureDetector(
                onTap: () => onCategoryTap(label),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text('Popular Searches', style: theme.textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                      'running shoes',
                      'wireless earbuds',
                      'backpack',
                      'laptop',
                      't-shirt',
                      'watch',
                    ]
                    .map(
                      (tag) => ActionChip(
                        label: Text(tag),
                        onPressed: () => onSearchTap(tag),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final VoidCallback onAskSahayak;
  const _EmptySearchState({required this.onAskSahayak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No matching products found.',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try asking Sahayak for help!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAskSahayak,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Ask Sahayak'),
          ),
        ],
      ),
    );
  }
}

class ProductDetailsSheet extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailsSheet({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsSheet> createState() =>
      _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends ConsumerState<ProductDetailsSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = widget.product;
    final cartState = ref.watch(cartViewModelProvider);
    final isAdding = cartState.loadingItems.contains(product.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (product.imageUrl != null &&
                          product.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            product.imageUrl!,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 240,
                              color: colorScheme.primaryContainer,
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(product.title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            CurrencyUtils.formatPaise(product.priceInPaise),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            product.isInStock
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                            size: 16,
                            color: product.isInStock
                                ? Colors.green
                                : colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.isInStock
                                ? 'In stock (${product.stockQty} available)'
                                : 'Out of stock',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: product.isInStock
                                  ? Colors.green
                                  : colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Description', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Quantity selector
                      if (product.isInStock) ...[
                        Text('Quantity', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _QuantityButton(
                              icon: Icons.remove_rounded,
                              onTap: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '$_quantity',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(width: 16),
                            _QuantityButton(
                              icon: Icons.add_rounded,
                              onTap: _quantity < product.stockQty
                                  ? () => setState(() => _quantity++)
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isAdding
                                ? null
                                : () async {
                                    final success = await ref
                                        .read(cartViewModelProvider.notifier)
                                        .addItem(
                                          product.id,
                                          quantity: _quantity,
                                        );
                                    if (success && context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${product.title} added to cart',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            icon: isAdding
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add_shopping_cart_rounded),
                            label: Text(isAdding ? 'Adding...' : 'Add to Cart'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(
            color: onTap != null ? colorScheme.primary : colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? colorScheme.primary : colorScheme.outline,
        ),
      ),
    );
  }
}
