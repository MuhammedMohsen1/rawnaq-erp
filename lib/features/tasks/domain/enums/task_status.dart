import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Status of a task in the system
enum TaskStatus {
  /// Task is currently being worked on
  inProgress,

  /// Task has been completed
  completed,

  /// Task is waiting/pending
  waiting,

  /// Task is delayed/overdue
  delayed,
}

/// Extension methods for TaskStatus
extension TaskStatusExtension on TaskStatus {
  /// Get the Arabic display name for the status
  String get arabicName {
    switch (this) {
      case TaskStatus.inProgress:
        return 'قيد التنفيذ';
      case TaskStatus.completed:
        return 'مكتمل';
      case TaskStatus.waiting:
        return 'في الانتظار';
      case TaskStatus.delayed:
        return 'متأخر';
    }
  }

  /// Get the English display name for the status
  String get englishName {
    switch (this) {
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.waiting:
        return 'Waiting';
      case TaskStatus.delayed:
        return 'Delayed';
    }
  }

  /// Get the color associated with this status
  Color get color {
    switch (this) {
      case TaskStatus.inProgress:
        return AppColors.statusActive; // Blue
      case TaskStatus.completed:
        return AppColors.statusCompleted; // Green
      case TaskStatus.waiting:
        return AppColors.statusOnHold; // Amber/Yellow
      case TaskStatus.delayed:
        return AppColors.statusDelayed; // Red
    }
  }

  /// Get display name based on locale
  String getDisplayName(String locale) {
    return locale == 'ar' ? arabicName : englishName;
  }

  /// Convert status to string for API
  String toApiString() {
    return name;
  }

  /// Create status from API string
  static TaskStatus fromApiString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskStatus.waiting,
    );
  }
}

