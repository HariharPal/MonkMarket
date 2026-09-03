import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monkmarket_client/app/constants/app_constants.dart';
import 'package:monkmarket_client/features/checkout/models/checkout.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../payment/viewmodels/payment_viewmodel.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  final Razorpay _razorpay = Razorpay();
  Duration? _remaining;

  @override
  void initState() {
    super.initState();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _startCountdown();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startCountdown() {
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    final checkout = ref.read(paymentViewModelProvider).currentCheckout;
    final remaining = checkout?.timeUntilExpiry;
    setState(() => _remaining = remaining);
    if (remaining != null && remaining > Duration.zero) {
      Future.delayed(const Duration(seconds: 1), _tick);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final message = response.message ?? 'Payment failed.';

    ref.read(paymentViewModelProvider.notifier).setPaymentFailed(message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'External wallet selected: ${response.walletName ?? 'Unknown'}',
        ),
      ),
    );
  }

  Future<void> _proceedToPayment() async {
    final paymentState = ref.read(paymentViewModelProvider);
    final checkout = paymentState.currentCheckout;

    if (checkout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active payment session.')),
      );
      return;
    }

    if (checkout.orderId == null || checkout.orderId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order ID is missing.')));
      return;
    }

    if (checkout.razorpayOrderId != null &&
        checkout.razorpayOrderId!.isNotEmpty) {
      _openRazorpay(checkout);
      return;
    }

    /*
   * Fallback:
   * If the agent response did not contain a Razorpay order,
   * ask Commerce to create/retrieve the payment session.
   */
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Razorpay payment requires the mobile app.'),
        ),
      );
      return;
    }

    final success = await ref
        .read(paymentViewModelProvider.notifier)
        .createPaymentOrder(checkout.orderId!);

    if (!mounted) return;

    if (!success) {
      final error = ref.read(paymentViewModelProvider).error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Unable to initialize payment.')),
      );

      return;
    }

    final updatedCheckout = ref.read(paymentViewModelProvider).currentCheckout;

    if (updatedCheckout == null ||
        updatedCheckout.razorpayOrderId == null ||
        updatedCheckout.razorpayOrderId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment session was not created correctly.'),
        ),
      );

      return;
    }

    _openRazorpay(updatedCheckout);
  }

  void _openRazorpay(Checkout checkout) {
    if (checkout.razorpayOrderId == null || checkout.razorpayOrderId!.isEmpty) {
      ref
          .read(paymentViewModelProvider.notifier)
          .setPaymentFailed('Razorpay order ID is missing.');
      return;
    }

    final options = {
      'key': AppConstants.razorpayKeyId,
      'amount': checkout.amountInPaise,
      'currency': checkout.currency,
      'name': 'MonkMarket',
      'description': 'MonkMarket Order',
      'order_id': checkout.razorpayOrderId,
      'timeout': 60,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ref
          .read(paymentViewModelProvider.notifier)
          .setPaymentFailed('Could not open Razorpay Checkout: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final checkout = ref.read(paymentViewModelProvider).currentCheckout;

    if (checkout == null || checkout.orderId == null) {
      ref
          .read(paymentViewModelProvider.notifier)
          .setPaymentFailed(
            'Payment succeeded but the order information is missing.',
          );
      return;
    }

    final success = await ref
        .read(paymentViewModelProvider.notifier)
        .verifyPayment(
          orderId: checkout.orderId!,
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verified successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentViewModelProvider);
    final checkout = paymentState.currentCheckout;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (checkout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active payment session.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/chat'),
                child: const Text('Go to Chat'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.payment_rounded,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Required',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyUtils.formatPaise(checkout.amountInPaise),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_remaining != null && _remaining! > Duration.zero) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: _remaining!.inMinutes < 2
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expires in ${AppDateUtils.formatCountdown(_remaining!)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _remaining!.inMinutes < 2
                                  ? colorScheme.error
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (paymentState.status == PaymentFlowStatus.success)
              _PaymentSuccessView(
                orderId: checkout.orderId,
                onViewOrder: () {
                  if (checkout.orderId != null) {
                    context.push('/orders/${checkout.orderId}');
                  }
                },
                onContinue: () => context.go('/home'),
              )
            else if (paymentState.status == PaymentFlowStatus.failed)
              _PaymentFailedView(
                error: paymentState.error,
                onRetry: _proceedToPayment,
                onContinue: () => context.go('/home'),
              )
            else ...[
              ElevatedButton.icon(
                onPressed: paymentState.isProcessing ? null : _proceedToPayment,
                icon: paymentState.isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_rounded),
                label: Text(
                  paymentState.isProcessing
                      ? 'Processing...'
                      : 'Proceed to Payment',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/chat'),
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentSuccessView extends StatelessWidget {
  final String? orderId;
  final VoidCallback onViewOrder;
  final VoidCallback onContinue;

  const _PaymentSuccessView({
    this.orderId,
    required this.onViewOrder,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 64,
          color: Colors.green.shade600,
        ),
        const SizedBox(height: 16),
        Text('Payment Successful!', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Your order has been placed.', style: theme.textTheme.bodyMedium),
        if (orderId != null) ...[
          const SizedBox(height: 4),
          Text(
            'Order ID: #${orderId!.length > 8 ? orderId!.substring(0, 8) : orderId}',
            style: theme.textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onViewOrder, child: const Text('View Order')),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onContinue,
          child: const Text('Continue Shopping'),
        ),
      ],
    );
  }
}

class _PaymentFailedView extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  const _PaymentFailedView({
    this.error,
    required this.onRetry,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
        const SizedBox(height: 16),
        Text('Payment Failed', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          error ?? 'Your payment could not be completed.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry Payment')),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onContinue,
          child: const Text('Continue Shopping'),
        ),
      ],
    );
  }
}
