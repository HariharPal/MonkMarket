import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime dateTime) {
    return DateFormat('d MMM yyyy').format(dateTime.toLocal());
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('d MMM yyyy, h:mm a').format(dateTime.toLocal());
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }

  static String formatCountdown(Duration duration) {
    if (duration.isNegative) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static DateTime? parseIso8601(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
