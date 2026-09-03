import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// V1 — M3 Refined: NavigationBar with tonal indicator pill + filled/outline icon swap — LOCKED

class _TabSpec {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? branchIndex;

  const _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedVisualIndex = 0;

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Orders',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      branchIndex: 1, // stub
    ),
    _TabSpec(
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
      branchIndex: 2,
    ),
    _TabSpec(
      label: 'Audit',
      icon: Icons.history_outlined,
      selectedIcon: Icons.history_rounded,
      branchIndex: 3,
    ),
    _TabSpec(
      label: 'More',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      branchIndex: null, // stub
    ),
  ];

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];
    if (tab.branchIndex == null) return; // stub — silently ignored

    setState(() => _selectedVisualIndex = visualIndex);
    widget.navigationShell.goBranch(
      tab.branchIndex!,
      initialLocation: tab.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationBar(
      selectedIndex: _selectedVisualIndex,
      onDestinationSelected: _onTabTap,
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: theme.colorScheme.primaryContainer,
      elevation: 3,
      shadowColor: theme.colorScheme.outline.withAlpha(77),
      destinations: List.generate(_tabs.length, (i) {
        final tab = _tabs[i];
        final isStub = tab.branchIndex == null;
        return NavigationDestination(
          icon: Opacity(opacity: isStub ? 0.4 : 1.0, child: Icon(tab.icon)),
          selectedIcon: Opacity(
            opacity: isStub ? 0.4 : 1.0,
            child: Icon(tab.selectedIcon),
          ),
          label: tab.label,
        );
      }),
    );
  }
}
