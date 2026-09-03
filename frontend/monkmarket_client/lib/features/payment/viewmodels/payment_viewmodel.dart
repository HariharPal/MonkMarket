import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../checkout/models/checkout.dart';
import '../../payment/repositories/payment_repository.dart';
import '../../../shared/providers/providers.dart';

enum PaymentFlowStatus { idle, processing, success, failed, expired }

class PaymentState {
  final Checkout? currentCheckout;
  final PaymentFlowStatus status;
  final bool isProcessing;
  final String? error;

  const PaymentState({
    this.currentCheckout,
    this.status = PaymentFlowStatus.idle,
    this.isProcessing = false,
    this.error,
  });

  PaymentState copyWith({
    Checkout? currentCheckout,
    PaymentFlowStatus? status,
    bool? isProcessing,
    String? error,
    bool clearError = false,
    bool clearCheckout = false,
  }) {
    return PaymentState(
      currentCheckout: clearCheckout
          ? null
          : (currentCheckout ?? this.currentCheckout),
      status: status ?? this.status,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PaymentViewModel extends StateNotifier<PaymentState> {
  final PaymentRepository _repository;

  PaymentViewModel(this._repository) : super(const PaymentState());

  void setCheckout(Checkout checkout) {
    state = state.copyWith(
      currentCheckout: checkout,
      status: PaymentFlowStatus.idle,
      clearError: true,
    );
  }

  Future<bool> createPaymentOrder(String orderId) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final checkout = await _repository.createPaymentOrder(orderId);

      state = state.copyWith(
        currentCheckout: checkout,
        status: PaymentFlowStatus.idle,
        isProcessing: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        status: PaymentFlowStatus.failed,
        error: e.toString().replaceFirst('ApiException: ', ''),
      );

      return false;
    }
  }

  Future<bool> verifyPayment({
    required String orderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      await _repository.verifyPayment(
        orderId: orderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      state = state.copyWith(
        isProcessing: false,
        status: PaymentFlowStatus.success,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        status: PaymentFlowStatus.failed,
        error: e.toString().replaceFirst('ApiException: ', ''),
      );

      return false;
    }
  }

  void setPaymentFailed(String? reason) {
    state = state.copyWith(
      status: PaymentFlowStatus.failed,
      isProcessing: false,
      error: reason ?? 'Payment was not completed.',
    );
  }

  void reset() {
    state = const PaymentState();
  }
}

final paymentViewModelProvider =
    StateNotifierProvider<PaymentViewModel, PaymentState>((ref) {
      return PaymentViewModel(ref.watch(paymentRepositoryProvider));
    });
