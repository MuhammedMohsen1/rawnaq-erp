/// Status of a project in the system
enum ProjectStatus {
  /// Project is actively being worked on
  active,
  
  /// Project has been completed successfully
  completed,
  
  /// Project is behind schedule
  delayed,
  
  /// Project is temporarily paused
  onHold,
}

/// Extension methods for ProjectStatus
extension ProjectStatusExtension on ProjectStatus {
  /// Get the Arabic display name for the status
  String get arabicName {
    switch (this) {
      case ProjectStatus.active:
        return 'نشط';
      case ProjectStatus.completed:
        return 'مكتمل';
      case ProjectStatus.delayed:
        return 'متأخر';
      case ProjectStatus.onHold:
        return 'معلق';
    }
  }

  /// Get the English display name for the status
  String get englishName {
    switch (this) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.delayed:
        return 'Delayed';
      case ProjectStatus.onHold:
        return 'On Hold';
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
  static ProjectStatus fromApiString(String value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ProjectStatus.active,
    );
  }
}

