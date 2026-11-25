import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_type.dart';
import 'status_badge_widget.dart';
import 'progress_indicator_widget.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

/// Widget to display a single project as a card
class ProjectCardWidget extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCardWidget({
    super.key,
    required this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'ar');
    final clientName = project.clientName?.trim();
    final hasClientName = clientName != null && clientName.isNotEmpty;

    return Card(
      color: AppColors.of(context).cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.of(context).border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ArabicNumberTransformer.transform(
                            hasClientName ? clientName : project.name,
                          ),
                          style: AppTextStyles.of(context).h6,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasClientName) ...[
                          const SizedBox(height: 4),
                          Text(
                            ArabicNumberTransformer.transform(project.name),
                            style: AppTextStyles.of(context).bodyMedium
                                .copyWith(
                                  color: AppColors.of(context).textSecondary,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.of(context).textMuted,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    color: AppColors.of(context).cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.of(context).border),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.of(context).error,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'حذف',
                              style: TextStyle(
                                color: AppColors.of(context).error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Status badge
              Row(
                children: [
                  StatusBadgeWidget(status: project.status),
                  if (project.type == ProjectType.design) ...[
                    const SizedBox(width: 8),
                    const _DesignProjectBadge(),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Progress
              ProgressIndicatorWidget(
                progress: project.progress,
                status: project.status,
              ),

              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تاريخ البدء',
                          style: AppTextStyles.of(context).caption,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ArabicNumberTransformer.transform(
                            dateFormat.format(project.startDate),
                          ),
                          style: AppTextStyles.of(context).bodyMedium.copyWith(
                            color: AppColors.of(context).textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تاريخ الانتهاء',
                          style: AppTextStyles.of(context).caption,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ArabicNumberTransformer.transform(
                            dateFormat.format(project.endDate),
                          ),
                          style: AppTextStyles.of(context).bodyMedium.copyWith(
                            color: AppColors.of(context).textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Manager info
              if (project.manager != null) ...[
                const SizedBox(height: 16),
                Divider(color: AppColors.of(context).divider),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.of(context).surfaceColor,
                      child: Text(
                        ArabicNumberTransformer.transform(
                          project.manager!.name.substring(0, 1),
                        ),
                        style: AppTextStyles.of(context).bodyMedium.copyWith(
                          color: AppColors.of(context).primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ArabicNumberTransformer.transform(
                              project.manager!.name,
                            ),
                            style: AppTextStyles.of(context).bodyMedium
                                .copyWith(
                                  color: AppColors.of(context).textPrimary,
                                ),
                          ),
                          Text(
                            ArabicNumberTransformer.transform(
                              project.manager!.role,
                            ),
                            style: AppTextStyles.of(context).caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DesignProjectBadge extends StatelessWidget {
  const _DesignProjectBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'تصميم',
        style: TextStyle(
          color: Color(0xFF60A5FA),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
