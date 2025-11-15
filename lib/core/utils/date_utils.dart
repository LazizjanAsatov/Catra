import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtilsHelper {
  static final _dateFormat = DateFormat.yMMMd();

  static String format(DateTime? date) {
    if (date == null) return 'No expiry';
    return _dateFormat.format(date);
  }

  static Color expiryColor(DateTime? date) {
    if (date == null) return Colors.grey;
    final days = date.difference(DateTime.now()).inDays;
    if (days <= 2) return Colors.red;
    if (days <= 5) return Colors.orange;
    return Colors.green;
  }
}
