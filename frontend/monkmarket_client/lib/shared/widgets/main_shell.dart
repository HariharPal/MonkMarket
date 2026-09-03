import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/cart/viewmodels/cart_viewmodel.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final String location;

  const MainShell({super.key, required this.child, required this.location});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _routes = ['/home', '/chat', '/cart', '/orders', '/profile'];

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIndex();
  }

  @override
  void initState() {
    super.initState();

    _updateIndex();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartViewModelProvider.notifier).loadCart();
    });
  }

  void _updateIndex() {
    final loc = widget.location;
    for (int i = 0; i < _routes.length; i++) {
      if (loc.startsWith(_routes[i])) {
        if (_currentIndex != i) {
          setState(() => _currentIndex = i);
        }
        return;
      }
    }
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final cartCount = cartState.itemCount;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
