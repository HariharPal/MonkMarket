import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../features/dashboard/models/dashboard_summary.dart';
import '../../../features/dashboard/viewmodels/dashboard_viewmodel.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/loading_skeleton_widget.dart';

class DashboardKpiGridWidget extends ConsumerWidget {
  const DashboardKpiGridWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return summaryAsync.when(
      loading: () => _buildSkeletonGrid(isTablet),
      error: (e, _) => _buildErrorCard(context, ref, e.toString()),
      data: (summary) => _buildKpiGrid(context, summary, isTablet),
    );
  }

  Widget _buildSkeletonGrid(bool isTablet) {
    final count = isTablet ? 6 : 6;
    final crossAxisCount = isTablet ? 3 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isTablet ? 1.5 : 1.3,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const SkeletonKpiCard(),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.error.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Unable to load dashboard metrics.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.read(dashboardSummaryProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(
    BuildContext context,
    DashboardSummary summary,
    bool isTablet,
  ) {
    final metrics = _buildMetrics(summary);
    final crossAxisCount = isTablet ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isTablet ? 1.6 : 1.25,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        return _KpiCard(metric: metrics[index]);
      },
    );
  }

  List<_KpiMetric> _buildMetrics(DashboardSummary summary) {
    final revenue = summary.totalRevenueInRupees;
    final revenueStr = revenue >= 100000
        ? '₹${(revenue / 100000).toStringAsFixed(1)}L'
        : revenue >= 1000
        ? '₹${(revenue / 1000).toStringAsFixed(1)}K'
        : '₹${revenue.toStringAsFixed(0)}';

    return [
      _KpiMetric(
        label: 'Total Revenue',
        value: revenueStr,
        icon: Icons.currency_rupee_rounded,
        iconBg: AppTheme.primaryContainer,
        iconColor: AppTheme.primary,
        subtitle: 'All time',
        trend: null,
      ),
      _KpiMetric(
        label: 'Total Orders',
        value: summary.totalOrders.toString(),
        icon: Icons.receipt_long_rounded,
        iconBg: const Color(0xFFDCEAFE),
        iconColor: AppTheme.info,
        subtitle: 'All time',
        trend: null,
      ),
      _KpiMetric(
        label: 'Paid Orders',
        value: summary.paidOrders.toString(),
        icon: Icons.check_circle_rounded,
        iconBg: AppTheme.successContainer,
        iconColor: AppTheme.success,
        subtitle: 'Captured',
        trend: summary.totalOrders > 0
            ? '${(summary.paidOrders / summary.totalOrders * 100).toStringAsFixed(0)}% success'
            : '—',
      ),
      _KpiMetric(
        label: 'Pending Payments',
        value: summary.pendingPayments.toString(),
        icon: Icons.schedule_rounded,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: AppTheme.warning,
        subtitle: 'Awaiting capture',
        isAlert: summary.pendingPayments > 0,
      ),
      _KpiMetric(
        label: 'Failed Payments',
        value: summary.failedPayments.toString(),
        icon: Icons.cancel_rounded,
        iconBg: AppTheme.errorContainer,
        iconColor: AppTheme.error,
        subtitle: 'Requires review',
        isAlert: summary.failedPayments > 0,
      ),
      _KpiMetric(
        label: 'AI-Assisted Orders',
        value: summary.aiAssistedOrders.toString(),
        icon: Icons.smart_toy_rounded,
        iconBg: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF7C3AED),
        subtitle: 'Via Sahayak',
        trend: summary.totalOrders > 0
            ? '${(summary.aiAssistedOrders / summary.totalOrders * 100).toStringAsFixed(0)}% of orders'
            : '—',
      ),
    ];
  }
}

class _KpiMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String subtitle;
  final String? trend;
  final bool isAlert;

  const _KpiMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.subtitle,
    this.trend,
    this.isAlert = false,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiMetric metric;

  const _KpiCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: metric.isAlert
            ? metric.iconBg.withAlpha(128)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: metric.isAlert
            ? Border.all(color: metric.iconColor.withAlpha(77))
            : Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: metric.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(metric.icon, color: metric.iconColor, size: 17),
              ),
              if (metric.isAlert)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: metric.iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: metric.isAlert
                      ? metric.iconColor
                      : theme.colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metric.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (metric.trend != null) ...[
                const SizedBox(height: 2),
                Text(
                  metric.trend!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: metric.iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
