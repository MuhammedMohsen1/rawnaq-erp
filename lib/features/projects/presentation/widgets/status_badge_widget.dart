import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/project_status.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

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
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        ArabicNumberTransformer.transform(status.arabicName),
        style: TextStyle(
          color: _getTextColor(context),
          fontSize: isCompact ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (status) {
      case ProjectStatus.draft:
        return AppColors.of(context).textMuted.withValues(alpha: 0.15);
      case ProjectStatus.underPricing:
        return AppColors.of(context).info.withValues(alpha: 0.15);
      case ProjectStatus.pendingSignature:
        return AppColors.of(context).warning.withValues(alpha: 0.15);
      case ProjectStatus.approved:
        return AppColors.of(context).statusCompleted.withValues(alpha: 0.15);

      case ProjectStatus.execution:
        return AppColors.of(context).statusActive.withValues(alpha: 0.15);
      case ProjectStatus.completed:
        return AppColors.of(context).statusCompleted.withValues(alpha: 0.15);
      case ProjectStatus.cancelled:
        return AppColors.of(context).statusDelayed.withValues(alpha: 0.15);
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (status) {
      case ProjectStatus.draft:
        return AppColors.of(context).textMuted;
      case ProjectStatus.underPricing:
        return AppColors.of(context).info;
      case ProjectStatus.pendingSignature:
        return AppColors.of(context).warning;
      case ProjectStatus.approved:
        return AppColors.of(context).statusCompleted;

      case ProjectStatus.execution:
        return AppColors.of(context).statusActive;
      case ProjectStatus.completed:
        return AppColors.of(context).statusCompleted;
      case ProjectStatus.cancelled:
        return AppColors.of(context).statusDelayed;
    }
  }
}
