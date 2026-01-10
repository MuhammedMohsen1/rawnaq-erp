import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

/// Utilities for pricing status
class PricingStatusUtils {
  /// Get status color based on pricing status
  static Color getStatusColor(String? status) {
    if (status == null) return AppColors.info;

    switch (status.toUpperCase()) {
      case 'DRAFT':
        return AppColors.textMuted;
      case 'PENDING_SIGNATURE':
        return AppColors.warning;
      case 'PENDING_APPROVAL':
        return AppColors.warning;
      case 'APPROVED':
        return AppColors.statusCompleted;
      case 'REJECTED':
        return AppColors.statusDelayed;
      default:
        return AppColors.info;
    }
  }

  /// Format last save time for display
  static String? formatLastSaveTime(DateTime? dateTime) {
    if (dateTime == null) return null;

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // If less than a minute ago, return null (will show "الآن" in UI)
    if (difference.inSeconds < 60) {
      return null;
    }

    // If less than an hour ago, show minutes
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return 'منذ $minutes ${minutes == 1 ? 'دقيقة' : 'دقائق'}';
    }

    // If less than a day ago, show hours
    if (difference.inDays < 1) {
      final hours = difference.inHours;
      return 'منذ $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
    }

    // If less than a week ago, show days
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'منذ $days ${days == 1 ? 'يوم' : 'أيام'}';
    }

    // If less than a month ago, show weeks
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
    }

    // Otherwise, show formatted date in Arabic format
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');
    return dateFormat.format(dateTime);
  }
}
