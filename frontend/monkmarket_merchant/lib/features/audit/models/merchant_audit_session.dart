class MerchantAuditSession {
  final String sessionId;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? checkoutState;
  final String? checkoutOrderId;
  final String? checkoutPaymentId;
  final String? checkoutRazorpayOrderId;

  const MerchantAuditSession({
    required this.sessionId,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.checkoutState,
    this.checkoutOrderId,
    this.checkoutPaymentId,
    this.checkoutRazorpayOrderId,
  });

  factory MerchantAuditSession.fromMap(Map<String, dynamic> map) {
    return MerchantAuditSession(
      sessionId:
          map['sessionId']?.toString() ?? map['session_id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? map['user_id']?.toString() ?? '',
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
      checkoutState:
          map['checkoutState']?.toString() ?? map['checkout_state']?.toString(),
      checkoutOrderId:
          map['checkoutOrderId']?.toString() ??
          map['checkout_order_id']?.toString(),
      checkoutPaymentId:
          map['checkoutPaymentId']?.toString() ??
          map['checkout_payment_id']?.toString(),
      checkoutRazorpayOrderId:
          map['checkoutRazorpayOrderId']?.toString() ??
          map['checkout_razorpay_order_id']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}
