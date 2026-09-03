class MerchantAuditUser {
  final String userId;
  final int sessionCount;
  final int messageCount;

  const MerchantAuditUser({
    required this.userId,
    required this.sessionCount,
    required this.messageCount,
  });

  factory MerchantAuditUser.fromMap(Map<String, dynamic> map) {
    return MerchantAuditUser(
      userId: map['userId']?.toString() ?? map['user_id']?.toString() ?? '',
      sessionCount:
          (map['sessionCount'] as num?)?.toInt() ??
          (map['session_count'] as num?)?.toInt() ??
          0,
      messageCount:
          (map['messageCount'] as num?)?.toInt() ??
          (map['message_count'] as num?)?.toInt() ??
          0,
    );
  }
}
