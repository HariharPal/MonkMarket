import '../../core/app_export.dart';
import '../../features/auth/viewmodels/login_viewmodel.dart';
import '../../features/dashboard/viewmodels/dashboard_viewmodel.dart';
import './widgets/agent_status_banner_widget.dart';
import './widgets/dashboard_app_bar_widget.dart';
import './widgets/dashboard_kpi_grid_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/revenue_chart_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(dashboardSummaryProvider.notifier).refresh(),
      ref.read(revenueAnalyticsProvider.notifier).refresh(),
      ref.read(recentActivityProvider.notifier).refresh(),
    ]);
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out of the Merchant Control Center?',
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authRepositoryProvider).logout();
      if (mounted) context.go(AppRoutes.merchantLoginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App Bar
              DashboardAppBarWidget(onLogout: _onLogout),

              // Content
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Agent Status Banner
                    const AgentStatusBannerWidget(),
                    const SizedBox(height: 20),

                    // KPI Grid
                    const DashboardKpiGridWidget(),
                    const SizedBox(height: 20),

                    // Revenue Chart
                    const RevenueChartWidget(),
                    const SizedBox(height: 20),

                    // Recent Activity
                    const RecentActivityWidget(),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
