class AuditChatMessage {
  final String id;
  final String? requestId;
  final String role;
  final String content;
  final String? toolName;
  final String? toolInput;
  final String? toolOutput;
  final DateTime? createdAt;

  const AuditChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.requestId,
    this.toolName,
    this.toolInput,
    this.toolOutput,
    this.createdAt,
  });

  factory AuditChatMessage.fromMap(Map<String, dynamic> map) {
    return AuditChatMessage(
      id: map['id']?.toString() ?? '',
      requestId: map['requestId']?.toString() ?? map['request_id']?.toString(),
      role: map['role']?.toString() ?? 'UNKNOWN',
      content: map['content']?.toString() ?? '',
      toolName: map['toolName']?.toString() ?? map['tool_name']?.toString(),
      toolInput: map['toolInput']?.toString() ?? map['tool_input']?.toString(),
      toolOutput:
          map['toolOutput']?.toString() ?? map['tool_output']?.toString(),
      createdAt: DateTime.tryParse(
        map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '',
      ),
    );
  }
}

class AgentAuditRecord {
  final String id;
  final String requestId;
  final String? eventType;
  final String? requestMessage;
  final String? responseType;
  final String? modelName;
  final String? responseMessage;
  final int productCount;
  final int recommendationCount;
  final bool cartPresent;
  final bool checkoutPresent;
  final int actionCount;
  final bool success;
  final String? errorType;
  final String? errorMessage;
  final int latencyMs;
  final DateTime? createdAt;

  const AgentAuditRecord({
    required this.id,
    required this.requestId,
    this.eventType,
    this.requestMessage,
    this.responseType,
    this.modelName,
    this.responseMessage,
    required this.productCount,
    required this.recommendationCount,
    required this.cartPresent,
    required this.checkoutPresent,
    required this.actionCount,
    required this.success,
    this.errorType,
    this.errorMessage,
    required this.latencyMs,
    this.createdAt,
  });

  factory AgentAuditRecord.fromMap(Map<String, dynamic> map) {
    return AgentAuditRecord(
      id: map['id']?.toString() ?? '',
      requestId:
          map['requestId']?.toString() ?? map['request_id']?.toString() ?? '',
      eventType: map['eventType']?.toString() ?? map['event_type']?.toString(),
      requestMessage:
          map['requestMessage']?.toString() ??
          map['request_message']?.toString(),
      responseType:
          map['responseType']?.toString() ?? map['response_type']?.toString(),
      modelName: map['modelName']?.toString() ?? map['model_name']?.toString(),
      responseMessage:
          map['responseMessage']?.toString() ??
          map['response_message']?.toString(),
      productCount:
          (map['productCount'] as num?)?.toInt() ??
          (map['product_count'] as num?)?.toInt() ??
          0,
      recommendationCount:
          (map['recommendationCount'] as num?)?.toInt() ??
          (map['recommendation_count'] as num?)?.toInt() ??
          0,
      cartPresent:
          map['cartPresent'] as bool? ?? map['cart_present'] as bool? ?? false,
      checkoutPresent:
          map['checkoutPresent'] as bool? ??
          map['checkout_present'] as bool? ??
          false,
      actionCount:
          (map['actionCount'] as num?)?.toInt() ??
          (map['action_count'] as num?)?.toInt() ??
          0,
      success: map['success'] as bool? ?? false,
      errorType: map['errorType']?.toString() ?? map['error_type']?.toString(),
      errorMessage:
          map['errorMessage']?.toString() ?? map['error_message']?.toString(),
      latencyMs:
          (map['latencyMs'] as num?)?.toInt() ??
          (map['latency_ms'] as num?)?.toInt() ??
          0,
      createdAt: DateTime.tryParse(
        map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '',
      ),
    );
  }
}

class ToolAuditRecord {
  final String id;
  final String requestId;
  final String? eventType;
  final String operation;
  final String? targetType;
  final String? targetName;
  final String? httpMethod;
  final String? apiPath;
  final String? inputJson;
  final String? outputJson;
  final bool success;
  final String? errorType;
  final String? errorMessage;
  final int latencyMs;
  final DateTime? createdAt;

  const ToolAuditRecord({
    required this.id,
    required this.requestId,
    this.eventType,
    required this.operation,
    this.targetType,
    this.targetName,
    this.httpMethod,
    this.apiPath,
    this.inputJson,
    this.outputJson,
    required this.success,
    this.errorType,
    this.errorMessage,
    required this.latencyMs,
    this.createdAt,
  });

  factory ToolAuditRecord.fromMap(Map<String, dynamic> map) {
    return ToolAuditRecord(
      id: map['id']?.toString() ?? '',
      requestId:
          map['requestId']?.toString() ?? map['request_id']?.toString() ?? '',
      eventType: map['eventType']?.toString() ?? map['event_type']?.toString(),
      operation: map['operation']?.toString() ?? 'UNKNOWN',
      targetType:
          map['targetType']?.toString() ?? map['target_type']?.toString(),
      targetName:
          map['targetName']?.toString() ?? map['target_name']?.toString(),
      httpMethod:
          map['httpMethod']?.toString() ?? map['http_method']?.toString(),
      apiPath: map['apiPath']?.toString() ?? map['api_path']?.toString(),
      inputJson: map['inputJson']?.toString() ?? map['input_json']?.toString(),
      outputJson:
          map['outputJson']?.toString() ?? map['output_json']?.toString(),
      success: map['success'] as bool? ?? false,
      errorType: map['errorType']?.toString() ?? map['error_type']?.toString(),
      errorMessage:
          map['errorMessage']?.toString() ?? map['error_message']?.toString(),
      latencyMs:
          (map['latencyMs'] as num?)?.toInt() ??
          (map['latency_ms'] as num?)?.toInt() ??
          0,
      createdAt: DateTime.tryParse(
        map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '',
      ),
    );
  }
}

class MerchantAuditDetail {
  final String sessionId;
  final String userId;
  final List<AuditChatMessage> messages;
  final List<AgentAuditRecord> agentEvents;
  final List<ToolAuditRecord> toolEvents;

  const MerchantAuditDetail({
    required this.sessionId,
    required this.userId,
    required this.messages,
    required this.agentEvents,
    required this.toolEvents,
  });

  factory MerchantAuditDetail.fromMap(Map<String, dynamic> map) {
    return MerchantAuditDetail(
      sessionId:
          map['sessionId']?.toString() ?? map['session_id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? map['user_id']?.toString() ?? '',
      messages: _list(map['messages']).map(AuditChatMessage.fromMap).toList(),
      agentEvents: _list(
        map['agentEvents'] ?? map['agent_events'],
      ).map(AgentAuditRecord.fromMap).toList(),
      toolEvents: _list(
        map['toolEvents'] ?? map['tool_events'],
      ).map(ToolAuditRecord.fromMap).toList(),
    );
  }

  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
