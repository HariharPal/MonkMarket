import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_monkmarket/core/constants/app_constants.dart';
import 'package:merchant_monkmarket/core/network/api_client.dart';

import '../../auth/viewmodels/login_viewmodel.dart';
import '../models/activity_event.dart';
import '../models/dashboard_summary.dart';
import '../models/revenue_data_point.dart';
import '../repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ApiClient(baseUrl: AppConstants.commerceBaseUrl));
});

class DashboardSummaryNotifier extends AsyncNotifier<DashboardSummary> {
  @override
  Future<DashboardSummary> build() async {
    return await ref.read(dashboardRepositoryProvider).getDashboardSummary();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).getDashboardSummary(),
    );
  }
}

final dashboardSummaryProvider =
    AsyncNotifierProvider<DashboardSummaryNotifier, DashboardSummary>(
      DashboardSummaryNotifier.new,
    );

class RevenueAnalyticsNotifier extends AsyncNotifier<List<RevenueDataPoint>> {
  @override
  Future<List<RevenueDataPoint>> build() async {
    return await ref.read(dashboardRepositoryProvider).getRevenueAnalytics();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).getRevenueAnalytics(),
    );
  }
}

final revenueAnalyticsProvider =
    AsyncNotifierProvider<RevenueAnalyticsNotifier, List<RevenueDataPoint>>(
      RevenueAnalyticsNotifier.new,
    );

class RecentActivityNotifier extends AsyncNotifier<List<ActivityEvent>> {
  @override
  Future<List<ActivityEvent>> build() async {
    return await ref.read(dashboardRepositoryProvider).getRecentActivity();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).getRecentActivity(),
    );
  }
}

final recentActivityProvider =
    AsyncNotifierProvider<RecentActivityNotifier, List<ActivityEvent>>(
      RecentActivityNotifier.new,
    );
