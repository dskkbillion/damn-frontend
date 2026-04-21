import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// Formats a DateTime into a relative time string (e.g., "昨天", "15:30").
/// 
/// Note: This is a basic implementation. Consider using a dedicated package 
/// like `timeago` for more comprehensive relative time formatting.
String formatRelativeTime(DateTime? dateTime, BuildContext context) {
  if (dateTime == null) {
    return '';
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDate == today) {
    // Today: Show HH:mm
    return DateFormat.Hm(Localizations.localeOf(context).languageCode).format(dateTime);
  } else if (messageDate == yesterday) {
    // Yesterday: Show "昨天"
    return AppLocalizations.of(context).core_yesterday;
  } else if (now.difference(dateTime).inDays < 7) {
     // Within the last week: Show weekday name (e.g., "星期三")
     // Ensure intl provides localized weekday names or handle manually
     // Using 'EEEE' format might give full name (e.g., "Wednesday")
     // Using 'E' might give abbreviation (e.g., "Wed")
     return DateFormat.E(Localizations.localeOf(context).languageCode).format(dateTime); 
  } else {
    // Older than a week: Show MM/dd or yyyy/MM/dd
    // Check if it's in the current year
    if (dateTime.year == now.year) {
       return DateFormat.Md(Localizations.localeOf(context).languageCode).format(dateTime); // e.g., 8/15
    } else {
       return DateFormat.yMd(Localizations.localeOf(context).languageCode).format(dateTime); // e.g., 2023/8/15
    }
  }
} 