import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../models/activity_event.dart';
import '../models/dashboard_summary.dart';
import '../models/revenue_data_point.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await _apiClient.get(AppConstants.merchantDashboardPath);
      final data = response.data as Map<String, dynamic>;
      return DashboardSummary.fromMap(data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<List<RevenueDataPoint>> getRevenueAnalytics({
    int days = AppConstants.defaultChartDays,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConstants.merchantRevenueAnalyticsPath,
        queryParameters: {'days': days},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => RevenueDataPoint.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<List<ActivityEvent>> getRecentActivity({int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        AppConstants.merchantAuditPath,
        queryParameters: {'page': 0, 'size': limit, 'sort': 'timestamp,desc'},
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['content'] != null) {
        list = data['content'] as List<dynamic>;
      } else {
        list = [];
      }
      return list
          .map((e) => ActivityEvent.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Never _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      throw AppException.unauthorized();
    } else if (e.response?.statusCode == 403) {
      throw AppException.forbidden();
    } else if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      throw AppException.network();
    } else {
      throw AppException.server();
    }
  }
}
