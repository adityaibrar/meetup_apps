import 'package:intl/intl.dart';

/// Utility class untuk formatting tanggal dan mata uang.
class AppFormatters {
  AppFormatters._();

  /// Format harga ke Rupiah: "Rp 50.000"
  static String currency(dynamic price) {
    final number = price is String
        ? double.tryParse(price) ?? 0
        : (price as num);
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(number)}';
  }

  /// Format tanggal chat list: "14:30" untuk hari ini, "20/02" untuk hari lain
  static String chatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return DateFormat('HH:mm').format(date);
      }
      return DateFormat('dd/MM').format(date);
    } catch (e) {
      return '';
    }
  }

  /// Format jam pesan: "14:30"
  static String messageTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp.toLocal());
  }
}
