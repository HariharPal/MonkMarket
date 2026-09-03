enum ActivityEventSource {
  payment,
  order,
  agent,
  guardrail,
  product,
  webhook,
  commerce,
  unknown,
}

enum ActivityEventOutcome { success, failure, warning, info }

class ActivityEvent {
  final String id;
  final String operation;
  final ActivityEventSource source;
  final ActivityEventOutcome outcome;
  final DateTime timestamp;
  final String? orderId;
  final String? paymentId;
  final String? sessionId;
  final String? details;

  const ActivityEvent({
    required this.id,
    required this.operation,
    required this.source,
    required this.outcome,
    required this.timestamp,
    this.orderId,
    this.paymentId,
    this.sessionId,
    this.details,
  });

  factory ActivityEvent.fromMap(Map<String, dynamic> map) {
    return ActivityEvent(
      id: map['id'] as String? ?? map['event_id'] as String? ?? '',
      operation:
          map['operation'] as String? ??
          map['event_type'] as String? ??
          'UNKNOWN',
      source: _sourceFromString(map['source'] as String? ?? ''),
      outcome: _outcomeFromString(
        map['outcome'] as String? ??
            (map['success'] == true ? 'success' : 'failure'),
      ),
      timestamp:
          DateTime.tryParse(
            map['timestamp'] as String? ?? map['created_at'] as String? ?? '',
          ) ??
          DateTime.now(),
      orderId: map['orderId'] as String? ?? map['order_id'] as String?,
      paymentId: map['paymentId'] as String? ?? map['payment_id'] as String?,
      sessionId: map['sessionId'] as String? ?? map['session_id'] as String?,
      details: map['details'] as String? ?? map['message'] as String?,
    );
  }

  static ActivityEventSource _sourceFromString(String v) {
    switch (v.toUpperCase()) {
      case 'PAYMENT':
        return ActivityEventSource.payment;
      case 'ORDER':
        return ActivityEventSource.order;
      case 'AGENT':
        return ActivityEventSource.agent;
      case 'GUARDRAIL':
        return ActivityEventSource.guardrail;
      case 'PRODUCT':
        return ActivityEventSource.product;
      case 'WEBHOOK':
        return ActivityEventSource.webhook;
      case 'COMMERCE':
        return ActivityEventSource.commerce;
      default:
        return ActivityEventSource.unknown;
    }
  }

  static ActivityEventOutcome _outcomeFromString(String v) {
    switch (v.toUpperCase()) {
      case 'SUCCESS':
        return ActivityEventOutcome.success;
      case 'FAILURE':
      case 'FAILED':
        return ActivityEventOutcome.failure;
      case 'WARNING':
        return ActivityEventOutcome.warning;
      default:
        return ActivityEventOutcome.info;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'operation': operation,
    'source': source.name.toUpperCase(),
    'outcome': outcome.name.toUpperCase(),
    'timestamp': timestamp.toIso8601String(),
    'orderId': orderId,
    'paymentId': paymentId,
    'sessionId': sessionId,
    'details': details,
  };
}
