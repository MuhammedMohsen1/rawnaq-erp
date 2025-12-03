import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_entity.dart';
import 'status_badge_widget.dart';
import 'progress_indicator_widget.dart';

/// Widget to display projects in a table format
class ProjectTableWidget extends StatelessWidget {
  final List<ProjectEntity> projects;
  final VoidCallback? onRefresh;
  final Function(ProjectEntity)? onProjectTap;
  final Function(ProjectEntity)? onEditProject;
  final Function(ProjectEntity)? onDeleteProject;

  const ProjectTableWidget({
    super.key,
    required this.projects,
    this.onRefresh,
    this.onProjectTap,
    this.onEditProject,
    this.onDeleteProject,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'ar');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.tableHeader,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('اسم المشروع', style: AppTextStyles.tableHeader),
                ),
                Expanded(
                  flex: 1,
                  child: Text('الحالة', style: AppTextStyles.tableHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text('التقدم', style: AppTextStyles.tableHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text('تاريخ البدء', style: AppTextStyles.tableHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text('تاريخ الانتهاء', style: AppTextStyles.tableHeader),
                ),
                const SizedBox(width: 80), // Actions column
              ],
            ),
          ),

          // Table body
          Expanded(
            child: projects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد مشاريع',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: projects.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      final isEven = index % 2 == 0;

                      return InkWell(
                        onTap: onProjectTap != null
                            ? () => onProjectTap!(project)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          color: isEven
                              ? AppColors.tableRowEven
                              : AppColors.tableRowOdd,
                          child: Row(
                            children: [
                              // Project name
                              Expanded(
                                flex: 3,
                                child: Text(
                                  project.name,
                                  style: AppTextStyles.tableCellBold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Status badge
                              Expanded(
                                flex: 1,
                                child: StatusBadgeWidget(
                                  status: project.status,
                                  isCompact: true,
                                ),
                              ),

                              // Progress
                              Expanded(
                                flex: 2,
                                child: ProgressIndicatorWidget(
                                  progress: project.progress,
                                  status: project.status,
                                ),
                              ),

                              // Start date
                              Expanded(
                                flex: 2,
                                child: Text(
                                  dateFormat.format(project.startDate),
                                  style: AppTextStyles.tableCell,
                                ),
                              ),

                              // End date
                              Expanded(
                                flex: 2,
                                child: Text(
                                  dateFormat.format(project.endDate),
                                  style: AppTextStyles.tableCell,
                                ),
                              ),

                              // Actions
                              SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_horiz,
                                        color: AppColors.textMuted,
                                      ),
                                      color: AppColors.cardBackground,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility_outlined,
                                                  size: 18),
                                              SizedBox(width: 8),
                                              Text('عرض'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined,
                                                  size: 18),
                                              SizedBox(width: 8),
                                              Text('تعديل'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: AppColors.error,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'حذف',
                                                style: TextStyle(
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'view':
                                            onProjectTap?.call(project);
                                            break;
                                          case 'edit':
                                            onEditProject?.call(project);
                                            break;
                                          case 'delete':
                                            onDeleteProject?.call(project);
                                            break;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

