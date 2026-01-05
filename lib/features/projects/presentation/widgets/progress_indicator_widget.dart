import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/project_status.dart';

/// Widget to display project progress as a bar with percentage
class ProgressIndicatorWidget extends StatelessWidget {
  final int progress;
  final ProjectStatus? status;
  final bool showLabel;
  final double height;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    this.status,
    this.showLabel = true,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showLabel)
          SizedBox(
            width: 45,
            child: Text(
              '$progress%',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (showLabel) const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.progressBackground,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getProgressColor(),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor() {
    if (status != null) {
      switch (status!) {
        case ProjectStatus.draft:
          return AppColors.textMuted;
        case ProjectStatus.underPricing:
          return AppColors.info;
        case ProjectStatus.profitPending:
          return AppColors.warning;
        case ProjectStatus.pendingApproval:
          return AppColors.warning;
        case ProjectStatus.execution:
          return AppColors.statusActive;
        case ProjectStatus.completed:
          return AppColors.statusCompleted;
        case ProjectStatus.cancelled:
          return AppColors.statusDelayed;
      }
    }

    // Default color based on progress
    if (progress >= 100) {
      return AppColors.statusCompleted;
    } else if (progress >= 75) {
      return AppColors.statusActive;
    } else if (progress >= 50) {
      return AppColors.warning;
    } else {
      return AppColors.textMuted;
    }
  }
}

