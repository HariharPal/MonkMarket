class DashboardSummary {
  final int totalRevenueInPaise;
  final int totalOrders;
  final int paidOrders;
  final int pendingPayments;
  final int failedPayments;
  final int aiAssistedOrders;
  final int guardrailBlocks;
  final String agentStatus;
  final String storeName;

  const DashboardSummary({
    required this.totalRevenueInPaise,
    required this.totalOrders,
    required this.paidOrders,
    required this.pendingPayments,
    required this.failedPayments,
    required this.aiAssistedOrders,
    required this.guardrailBlocks,
    required this.agentStatus,
    required this.storeName,
  });

  factory DashboardSummary.fromMap(Map<String, dynamic> map) {
    return DashboardSummary(
      totalRevenueInPaise:
          (map['totalRevenueInPaise'] as num?)?.toInt() ??
          (map['total_revenue_in_paise'] as num?)?.toInt() ??
          0,
      totalOrders:
          (map['totalOrders'] as num?)?.toInt() ??
          (map['total_orders'] as num?)?.toInt() ??
          0,
      paidOrders:
          (map['paidOrders'] as num?)?.toInt() ??
          (map['paid_orders'] as num?)?.toInt() ??
          0,
      pendingPayments:
          (map['pendingPayments'] as num?)?.toInt() ??
          (map['pending_payments'] as num?)?.toInt() ??
          0,
      failedPayments:
          (map['failedPayments'] as num?)?.toInt() ??
          (map['failed_payments'] as num?)?.toInt() ??
          0,
      aiAssistedOrders:
          (map['aiAssistedOrders'] as num?)?.toInt() ??
          (map['ai_assisted_orders'] as num?)?.toInt() ??
          0,
      guardrailBlocks:
          (map['guardrailBlocks'] as num?)?.toInt() ??
          (map['guardrail_blocks'] as num?)?.toInt() ??
          0,
      agentStatus:
          map['agentStatus'] as String? ??
          map['agent_status'] as String? ??
          'UNKNOWN',
      storeName:
          map['storeName'] as String? ??
          map['store_name'] as String? ??
          'MonkMarket',
    );
  }

  Map<String, dynamic> toMap() => {
    'totalRevenueInPaise': totalRevenueInPaise,
    'totalOrders': totalOrders,
    'paidOrders': paidOrders,
    'pendingPayments': pendingPayments,
    'failedPayments': failedPayments,
    'aiAssistedOrders': aiAssistedOrders,
    'guardrailBlocks': guardrailBlocks,
    'agentStatus': agentStatus,
    'storeName': storeName,
  };

  double get totalRevenueInRupees => totalRevenueInPaise / 100.0;
}
