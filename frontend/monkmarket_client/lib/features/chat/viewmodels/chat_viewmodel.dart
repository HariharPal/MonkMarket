import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monkmarket_client/features/cart/viewmodels/cart_viewmodel.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message_ui_model.dart';
import '../repositories/agent_repository.dart';
import '../../checkout/models/checkout.dart';
import '../../../shared/providers/providers.dart';

class ChatState {
  final List<ChatMessageUiModel> messages;
  final String? sessionId;
  final bool isSending;
  final String? error;
  final Checkout? currentCheckout;

  const ChatState({
    this.messages = const [],
    this.sessionId,
    this.isSending = false,
    this.error,
    this.currentCheckout,
  });

  ChatState copyWith({
    List<ChatMessageUiModel>? messages,
    String? sessionId,
    bool? isSending,
    String? error,
    Checkout? currentCheckout,
    bool clearError = false,
    bool clearCheckout = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sessionId: sessionId ?? this.sessionId,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      currentCheckout: clearCheckout
          ? null
          : (currentCheckout ?? this.currentCheckout),
    );
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  final AgentRepository _repository;
  final Ref _ref;

  static const Uuid _uuid = Uuid();

  ChatViewModel(this._repository, this._ref)
    : super(
        ChatState(
          sessionId: _uuid.v4(),
          messages: [ChatMessageUiModel.welcome()],
        ),
      );

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isSending) return;

    final userMessage = ChatMessageUiModel.user(text.trim());
    final loadingMessage = ChatMessageUiModel.loading();

    print('SESSION ID: ${state.sessionId}');

    state = state.copyWith(
      messages: [...state.messages, userMessage, loadingMessage],
      isSending: true,
      clearError: true,
    );

    try {
      final response = await _repository.chat(
        text.trim(),
        sessionId: state.sessionId,
      );

      final assistantMessage = ChatMessageUiModel.fromResponse(response);
      final updatedMessages = state.messages.where((m) => !m.isLoading).toList()
        ..add(assistantMessage);

      Checkout? checkout = state.currentCheckout;
      if (response.checkout != null) {
        checkout = response.checkout;
      }

      if (response.cart != null) {
        _ref
            .read(cartViewModelProvider.notifier)
            .updateCartFromAgent(response.cart!);
      }

      state = state.copyWith(
        messages: updatedMessages,
        sessionId: response.sessionId.isNotEmpty
            ? response.sessionId
            : state.sessionId,
        isSending: false,
        currentCheckout: checkout,
      );
    } catch (e) {
      final updatedMessages = state.messages
          .where((m) => !m.isLoading)
          .toList();
      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  void startNewChat() {
    state = ChatState(
      sessionId: _uuid.v4(),
      messages: [ChatMessageUiModel.welcome()],
    );
  }

  void updateCheckout(Checkout checkout) {
    state = state.copyWith(currentCheckout: checkout);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((
  ref,
) {
  return ChatViewModel(ref.watch(agentRepositoryProvider), ref);
});
