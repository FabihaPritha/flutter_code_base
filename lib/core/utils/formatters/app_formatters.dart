import 'package:intl/intl.dart';

class AppForMatters {
  /// Format: `11-Sep-2025`
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  /// Format: `$1,234.56`
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  /// Format: (123) 456-7890 or (1234) 567-890
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
    } else if (phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)}-${phoneNumber.substring(7)}';
    }
    return phoneNumber;
  }

  /// Format: `2:09 PM`
  static String formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:$minute $suffix';
  }

  /// Format: `Sep 11, 2025 at 2:30 PM`
  static String formatDateTimeVerbose(DateTime dt) {
    final month = DateFormat('MMM').format(dt);
    final day = dt.day;
    final year = dt.year;
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final suffix = dt.hour >= 12 ? "PM" : "AM";
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$month $day, $year at $hour12:$minute $suffix";
  }

  /// Size: Converts bytes to KB/MB
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
}

// AppForMatters.formatTime(msg.timestamp)
// AppForMatters.formatDate(report.uploadedAt)
// AppForMatters.formatFileSize(report.sizeInBytes)
// AppForMatters.formatCurrency(1999.5)
