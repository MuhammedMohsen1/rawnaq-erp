import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/project_status.dart';

/// Widget to display project status as a badge
class StatusBadgeWidget extends StatelessWidget {
  final ProjectStatus status;
  final bool isCompact;

  const StatusBadgeWidget({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.arabicName,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: isCompact ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case ProjectStatus.active:
        return AppColors.statusActive.withValues(alpha: 0.15);
      case ProjectStatus.completed:
        return AppColors.statusCompleted.withValues(alpha: 0.15);
      case ProjectStatus.delayed:
        return AppColors.statusDelayed.withValues(alpha: 0.15);
      case ProjectStatus.onHold:
        return AppColors.statusOnHold.withValues(alpha: 0.15);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case ProjectStatus.active:
        return AppColors.statusActive;
      case ProjectStatus.completed:
        return AppColors.statusCompleted;
      case ProjectStatus.delayed:
        return AppColors.statusDelayed;
      case ProjectStatus.onHold:
        return AppColors.statusOnHold;
    }
  }
}

