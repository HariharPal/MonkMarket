import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../features/dashboard/viewmodels/dashboard_viewmodel.dart';
import '../../../theme/app_theme.dart';

class DashboardAppBarWidget extends ConsumerWidget {
  final VoidCallback onLogout;

  const DashboardAppBarWidget({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    final storeName = summaryAsync.when(
      data: (s) => s.storeName,
      loading: () => 'MonkMarket',
      error: (_, __) => 'MonkMarket',
    );

    return SliverAppBar(
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: theme.colorScheme.outline.withAlpha(102),
      floating: true,
      snap: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            storeName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            'Merchant Control Center',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh dashboard',
          onPressed: () async {
            await Future.wait([
              ref.read(dashboardSummaryProvider.notifier).refresh(),
              ref.read(revenueAnalyticsProvider.notifier).refresh(),
              ref.read(recentActivityProvider.notifier).refresh(),
            ]);
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            onPressed: onLogout,
            tooltip: 'Sign out',
          ),
        ),
      ],
    );
  }
}
