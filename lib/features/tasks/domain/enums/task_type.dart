import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Types of tasks in the system
enum TaskType {
  /// Work task related to a project (displayed as bar)
  workTask,

  /// Appointment with a client (displayed as circle)
  appointment,

  /// General task not related to any project (displayed as bar)
  generalTask,
}

/// Extension methods for TaskType
extension TaskTypeExtension on TaskType {
  /// Get the Arabic display name for the type
  String get arabicName {
    switch (this) {
      case TaskType.workTask:
        return 'مهمة مشروع';
      case TaskType.appointment:
        return 'موعد عميل';
      case TaskType.generalTask:
        return 'مهمة عامة';
    }
  }

  /// Get the English display name for the type
  String get englishName {
    switch (this) {
      case TaskType.workTask:
        return 'Project Task';
      case TaskType.appointment:
        return 'Appointment';
      case TaskType.generalTask:
        return 'General Task';
    }
  }

  /// Get the icon associated with this type
  IconData get icon {
    switch (this) {
      case TaskType.workTask:
        return Icons.work_outline;
      case TaskType.appointment:
        return Icons.calendar_today;
      case TaskType.generalTask:
        return Icons.task_alt;
    }
  }

  /// Get the color associated with this type
  Color get color {
    switch (this) {
      case TaskType.workTask:
        return AppColors.statusActive;
      case TaskType.appointment:
        return const Color(0xFF9C27B0); // Purple for appointments
      case TaskType.generalTask:
        return AppColors.statusOnHold;
    }
  }

  /// Check if this task type is displayed as a bar
  bool get isBar {
    return this != TaskType.appointment;
  }

  /// Check if this task type requires a project
  bool get requiresProject {
    return this == TaskType.workTask;
  }

  /// Get display name based on locale
  String getDisplayName(String locale) {
    return locale == 'ar' ? arabicName : englishName;
  }

  /// Convert type to string for API
  String toApiString() {
    return name;
  }

  /// Create type from API string
  static TaskType fromApiString(String value) {
    return TaskType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskType.generalTask,
    );
  }
}

