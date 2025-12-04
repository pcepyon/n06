import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Extension to format DateTime with locale awareness
///
/// Usage:
/// ```dart
/// Text(date.formatMedium(context))  // "12월 4일 (수)" or "Dec 4 (Wed)"
/// Text(date.formatFull(context))    // "2024년 12월 4일" or "December 4, 2024"
/// Text(date.formatTime(context))    // "14:30" or "2:30 PM"
/// ```
extension DateFormatL10n on DateTime {
  /// Format as "M월 d일 (E)" or "MMM d (E)"
  String formatMedium(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ko') {
      return DateFormat('M월 d일 (E)', 'ko_KR').format(this);
    } else {
      return DateFormat('MMM d (E)', 'en_US').format(this);
    }
  }

  /// Format as "yyyy년 M월 d일" or "MMMM d, yyyy"
  String formatFull(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ko') {
      return DateFormat('yyyy년 M월 d일', 'ko_KR').format(this);
    } else {
      return DateFormat('MMMM d, yyyy', 'en_US').format(this);
    }
  }

  /// Format as "HH:mm" or "h:mm a"
  String formatTime(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ko') {
      return DateFormat('HH:mm', 'ko_KR').format(this);
    } else {
      return DateFormat('h:mm a', 'en_US').format(this);
    }
  }

  /// Format as "M/d" or "M/d"
  String formatShort(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ko') {
      return DateFormat('M/d', 'ko_KR').format(this);
    } else {
      return DateFormat('M/d', 'en_US').format(this);
    }
  }

  /// Format as "yyyy-MM-dd"
  String formatIso() {
    return DateFormat('yyyy-MM-dd').format(this);
  }
}
