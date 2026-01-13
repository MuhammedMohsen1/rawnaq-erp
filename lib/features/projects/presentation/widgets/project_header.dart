import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';

/// Header widget displaying project name and status
class ProjectHeader extends StatelessWidget {
  final ProjectEntity project;

  const ProjectHeader({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                project.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.75,
                ),
              ),
            ),
            _StatusBadge(status: project.status),
          ],
        ),
      ],
    );
  }
}

/// Private widget for displaying project status badge
class _StatusBadge extends StatelessWidget {
  final ProjectStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final text = status.arabicName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case ProjectStatus.draft:
        return AppColors.textMuted;
      case ProjectStatus.underPricing:
        return AppColors.info;
      case ProjectStatus.pendingSignature:
        return AppColors.warning;
      case ProjectStatus.approved:
        return AppColors.statusCompleted;
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
}
