class RevenueDataPoint {
  final DateTime date;
  final int revenueInPaise;

  const RevenueDataPoint({required this.date, required this.revenueInPaise});

  factory RevenueDataPoint.fromMap(Map<String, dynamic> map) {
    return RevenueDataPoint(
      date:
          DateTime.tryParse(
            map['date'] as String? ?? map['timestamp'] as String? ?? '',
          ) ??
          DateTime.now(),
      revenueInPaise:
          (map['revenueInPaise'] as num?)?.toInt() ??
          (map['revenue_in_paise'] as num?)?.toInt() ??
          0,
    );
  }

  double get revenueInRupees => revenueInPaise / 100.0;
}
