class Checkout {
  final String? orderId;
  final String? paymentId;
  final String? razorpayOrderId;
  final int amountInPaise;
  final String currency;
  final String paymentStatus;
  final DateTime? expiresAt;

  const Checkout({
    this.orderId,
    this.paymentId,
    this.razorpayOrderId,
    required this.amountInPaise,
    required this.currency,
    required this.paymentStatus,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  factory Checkout.fromJson(Map<String, dynamic> json) {
    DateTime? expiresAt;
    if (json['expiresAt'] != null) {
      try {
        expiresAt = DateTime.parse(json['expiresAt'].toString());
      } catch (_) {}
    }
    return Checkout(
      orderId: json['orderId']?.toString(),
      paymentId: json['paymentId']?.toString(),
      razorpayOrderId: json['razorpayOrderId']?.toString(),
      amountInPaise: (json['amountInPaise'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      paymentStatus: json['paymentStatus']?.toString() ?? 'CREATED',
      expiresAt: expiresAt,
    );
  }
}

enum PaymentStatus { created, paid, failed, expired, unknown }

extension PaymentStatusExt on String {
  PaymentStatus toPaymentStatus() {
    switch (toUpperCase()) {
      case 'CREATED':
        return PaymentStatus.created;
      case 'PAID':
        return PaymentStatus.paid;
      case 'FAILED':
        return PaymentStatus.failed;
      case 'EXPIRED':
        return PaymentStatus.expired;
      default:
        return PaymentStatus.unknown;
    }
  }
}
