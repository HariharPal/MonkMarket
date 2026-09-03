import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/merchant_audit_detail.dart';
import '../models/merchant_audit_session.dart';
import '../models/merchant_audit_user.dart';
import '../repositories/audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository(ApiClient());
});

final merchantAuditUsersProvider =
    FutureProvider.autoDispose<List<MerchantAuditUser>>((ref) {
      return ref.read(auditRepositoryProvider).getUsers();
    });

final merchantAuditSessionsProvider = FutureProvider.autoDispose
    .family<List<MerchantAuditSession>, String>((ref, userId) {
      return ref.read(auditRepositoryProvider).getUserSessions(userId);
    });

final merchantAuditDetailProvider = FutureProvider.autoDispose
    .family<MerchantAuditDetail, String>((ref, sessionId) {
      return ref.read(auditRepositoryProvider).getSessionDetail(sessionId);
    });
