import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/merchant_audit_detail.dart';
import '../models/merchant_audit_session.dart';
import '../models/merchant_audit_user.dart';

class AuditRepository {
  final ApiClient _apiClient;

  AuditRepository(this._apiClient);

  Future<List<MerchantAuditUser>> getUsers() async {
    final response = await _apiClient.get('/api/v1/agent/audit/merchant/users');

    final data = response.data;

    if (data is! List) {
      throw const FormatException('Invalid audit users response');
    }

    return data
        .whereType<Map>()
        .map(
          (item) => MerchantAuditUser.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<MerchantAuditSession>> getUserSessions(String userId) async {
    final response = await _apiClient.get(
      '/api/v1/agent/audit/merchant/users/$userId/sessions',
    );

    final data = response.data;

    if (data is! List) {
      throw const FormatException('Invalid audit sessions response');
    }

    return data
        .whereType<Map>()
        .map(
          (item) =>
              MerchantAuditSession.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<MerchantAuditDetail> getSessionDetail(String sessionId) async {
    final response = await _apiClient.get(
      '/api/v1/agent/audit/merchant/sessions/$sessionId',
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Invalid audit detail response');
    }

    return MerchantAuditDetail.fromMap(Map<String, dynamic>.from(data));
  }
}
