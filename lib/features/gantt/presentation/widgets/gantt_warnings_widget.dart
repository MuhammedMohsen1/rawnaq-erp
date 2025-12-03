import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../projects/domain/entities/team_member_entity.dart';

/// Widget to display warnings/alerts for the Gantt chart
class GanttWarningsWidget extends StatelessWidget {
  final List<TeamMemberEntity> overloadedMembers;
  final List<String> delayedProjects;
  final VoidCallback? onDismiss;

  const GanttWarningsWidget({
    super.key,
    required this.overloadedMembers,
    required this.delayedProjects,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (overloadedMembers.isEmpty && delayedProjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusDelayed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.statusDelayed.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.statusDelayed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تحذيرات هامة',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.statusDelayed,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.statusDelayed,
                    size: 20,
                  ),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Overloaded team members warning
          if (overloadedMembers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.textPrimary)),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: '${overloadedMembers.length} موظفين يتجاوزون طاقة العمل هذا الأسبوع: ',
                          ),
                          TextSpan(
                            text: overloadedMembers.map((m) => m.name).join('، '),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.statusDelayed,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Delayed projects warning
          if (delayedProjects.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.textPrimary)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        const TextSpan(text: 'مشروع "'),
                        TextSpan(
                          text: delayedProjects.first,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusDelayed,
                          ),
                        ),
                        const TextSpan(text: '" متأخر عن الموعد المحدد.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

