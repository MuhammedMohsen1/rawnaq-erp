import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';
import 'project_contact_actions.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

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
                ArabicNumberTransformer.transform(project.name),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.of(context).textPrimary,
                  letterSpacing: -0.75,
                ),
              ),
            ),
            ProjectContactActions(
              contacts: project.clientContacts,
              fallbackPhone: project.clientPhone,
              fallbackName: project.clientName,
              googleMapLink: project.googleMapLink,
              onCopy: (Sting, String) {},
            ),
            const SizedBox(width: 10),
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
    final color = _getStatusColor(context);
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
            ArabicNumberTransformer.transform(text),
            style: AppTextStyles.of(context).caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
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
