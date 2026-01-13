/// Status of a project in the system
/// Matches the Prisma schema: DRAFT, UNDER_PRICING, PENDING_SIGNATURE, PENDING_APPROVAL, EXECUTION, COMPLETED, CANCELLED
enum ProjectStatus {
  /// Project is in draft stage
  draft,

  /// Project is under pricing review
  underPricing,

  /// Project is pending approval
  pendingApproval,

  /// Project is  approved
  approved,

  /// Project is  pending signature
  pendingSignature,

  /// Project is in execution phase
  execution,

  /// Project has been completed successfully
  completed,

  /// Project has been cancelled
  cancelled,
}

/// Extension methods for ProjectStatus
extension ProjectStatusExtension on ProjectStatus {
  /// Get the Arabic display name for the status
  String get arabicName {
    switch (this) {
      case ProjectStatus.draft:
        return 'مسودة';
      case ProjectStatus.underPricing:
        return 'قيد التسعير';

      case ProjectStatus.pendingApproval:
        return 'في انتظار الموافقة';
      case ProjectStatus.approved:
        return 'موافق عليه';
      case ProjectStatus.pendingSignature:
        return 'في انتظار التوقيع';
      case ProjectStatus.execution:
        return 'قيد التنفيذ';
      case ProjectStatus.completed:
        return 'مكتمل';
      case ProjectStatus.cancelled:
        return 'ملغي';
    }
  }

  /// Get the English display name for the status
  String get englishName {
    switch (this) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.underPricing:
        return 'Under Pricing';
      case ProjectStatus.pendingSignature:
        return 'Pending Signature';
      case ProjectStatus.pendingApproval:
        return 'Pending Approval';
      case ProjectStatus.approved:
        return 'Approved';

      case ProjectStatus.execution:
        return 'Execution';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get display name based on locale
  String getDisplayName(String locale) {
    return locale == 'ar' ? arabicName : englishName;
  }

  /// Convert status to string for API (uppercase with underscores)
  String toApiString() {
    switch (this) {
      case ProjectStatus.draft:
        return 'DRAFT';
      case ProjectStatus.underPricing:
        return 'UNDER_PRICING';
      case ProjectStatus.pendingSignature:
        return 'PENDING_SIGNATURE';
      case ProjectStatus.approved:
        return 'PENDING_SIGNATURE';
      case ProjectStatus.pendingApproval:
        return 'PENDING_APPROVAL';
      case ProjectStatus.execution:
        return 'EXECUTION';
      case ProjectStatus.completed:
        return 'COMPLETED';
      case ProjectStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Create status from API string
  static ProjectStatus fromApiString(String value) {
    final upperValue = value.toUpperCase();
    switch (upperValue) {
      case 'DRAFT':
        return ProjectStatus.draft;
      case 'UNDER_PRICING':
        return ProjectStatus.underPricing;
      case 'PENDING_SIGNATURE':
        return ProjectStatus.pendingSignature;
      case 'PENDING_APPROVAL':
        return ProjectStatus.pendingApproval;
      case 'EXECUTION':
        return ProjectStatus.execution;
      case 'COMPLETED':
        return ProjectStatus.completed;
      case 'CANCELLED':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.draft;
    }
  }
}
