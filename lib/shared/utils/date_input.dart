import 'package:flutter/services.dart';

class DateInput {
  static final DateTime defaultMinDate = DateTime(1900, 1, 1);
  static final DateTime defaultMaxDate = DateTime(2100, 12, 31);

  static DateTime? tryParseDayMonthYear(
    String input, {
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    final normalized = input.trim();
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(normalized)) return null;

    final parts = normalized.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;

    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }

    final min = minDate ?? defaultMinDate;
    final max = maxDate ?? defaultMaxDate;
    if (date.isBefore(min) || date.isAfter(max)) {
      return null;
    }

    return date;
  }

  static String formatDayMonthYear(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }
}

class DayMonthYearTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digitsOnly.length > 8
        ? digitsOnly.substring(0, 8)
        : digitsOnly;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      if (i == 1 || i == 3) {
        if (i != limited.length - 1) {
          buffer.write('/');
        }
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}
