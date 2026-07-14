import 'package:intl/intl.dart';

/// Currency and date formatting helpers for the dashboard.
class DashboardFormatters {
  DashboardFormatters._();

  static String currency(double amount, {String currencyCode = 'KES'}) {
    final formatter = NumberFormat.currency(
      symbol: currencyCode == 'KES' ? 'KES ' : '$currencyCode ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String creditScore(int? score) {
    if (score == null) return 'N/A';
    return '$score / 100';
  }

  static String meetingDate(DateTime date, {String? startTime}) {
    final formatted = DateFormat('EEE, d MMM yyyy').format(date);
    if (startTime == null || startTime.isEmpty) return formatted;
    return '$formatted · $startTime';
  }

  static String relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dateTime);
  }
}
