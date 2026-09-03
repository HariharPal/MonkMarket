import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static String formatPaise(int paise, {String currency = 'INR'}) {
    final amount = paise / 100.0;
    if (currency == 'INR') {
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: amount == amount.truncate() ? 0 : 2,
      );
      return formatter.format(amount);
    }
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  static String formatAmount(double amount, {String currency = 'INR'}) {
    return formatPaise((amount * 100).round(), currency: currency);
  }
}
