import 'package:intl/intl.dart';

// formatting helpers for money and dates
class Format {
  static final NumberFormat _peso = NumberFormat.currency(locale: "en_PH", symbol: "₱", decimalDigits: 2);
  static final NumberFormat _pesoShort = NumberFormat.currency(locale: "en_PH", symbol: "₱", decimalDigits: 0);

  static String peso(num value) => _peso.format(value);
  static String pesoShort(num value) => _pesoShort.format(value);

  static String date(String iso) {
    DateTime? d = DateTime.tryParse(iso);
    if (d == null) return "-";
    return DateFormat("MMM d, yyyy").format(d);
  }

  static String dateTime(String iso) {
    DateTime? d = DateTime.tryParse(iso);
    if (d == null) return "-";
    return DateFormat("MMM d, yyyy • h:mm a").format(d);
  }

  static String time(String iso) {
    DateTime? d = DateTime.tryParse(iso);
    if (d == null) return "-";
    return DateFormat("h:mm a").format(d);
  }

  static String timeAgo(String iso) {
    DateTime? d = DateTime.tryParse(iso);
    if (d == null) return "";
    Duration diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return date(iso);
  }

  static String now() => DateTime.now().toIso8601String();

  static String daysFromNow(int days) => DateTime.now().add(Duration(days: days)).toIso8601String();
}
