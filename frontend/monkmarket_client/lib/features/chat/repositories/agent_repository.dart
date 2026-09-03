import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../chat/models/agent_chat_response.dart';

class AgentRepository {
  final ApiClient _apiClient;

  AgentRepository(this._apiClient);

  Future<AgentChatResponse> chat(String message, {String? sessionId}) async {
    try {
      final body = <String, dynamic>{
        'message': message,
        'sessionId': sessionId,
      };
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.agentChat,
        data: body,
      );
      return AgentChatResponse.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
