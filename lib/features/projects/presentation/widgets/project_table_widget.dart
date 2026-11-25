import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_type.dart';
import 'status_badge_widget.dart';
import 'progress_indicator_widget.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

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
        color: AppColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.of(context).tableHeader,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'اسم المشروع',
                    style: AppTextStyles.of(context).tableHeader,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'الحالة',
                    style: AppTextStyles.of(context).tableHeader,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'التقدم',
                    style: AppTextStyles.of(context).tableHeader,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'تاريخ البدء',
                    style: AppTextStyles.of(context).tableHeader,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'تاريخ الانتهاء',
                    style: AppTextStyles.of(context).tableHeader,
                  ),
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
                          color: AppColors.of(context).textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد مشاريع',
                          style: AppTextStyles.of(context).bodyLarge.copyWith(
                            color: AppColors.of(context).textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: projects.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: AppColors.of(context).divider,
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
                              ? AppColors.of(context).tableRowEven
                              : AppColors.of(context).tableRowOdd,
                          child: Row(
                            children: [
                              // Project name
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ArabicNumberTransformer.transform(
                                          project.name,
                                        ),
                                        style: AppTextStyles.of(
                                          context,
                                        ).tableCellBold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (project.type == ProjectType.design)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Icon(
                                          Icons.palette_outlined,
                                          size: 16,
                                          color: Color(0xFF60A5FA),
                                        ),
                                      ),
                                  ],
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
                                  ArabicNumberTransformer.transform(
                                    dateFormat.format(project.startDate),
                                  ),
                                  style: AppTextStyles.of(context).tableCell,
                                ),
                              ),

                              // End date
                              Expanded(
                                flex: 2,
                                child: Text(
                                  ArabicNumberTransformer.transform(
                                    dateFormat.format(project.endDate),
                                  ),
                                  style: AppTextStyles.of(context).tableCell,
                                ),
                              ),

                              // Actions
                              SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_horiz,
                                        color: AppColors.of(context).textMuted,
                                      ),
                                      color: AppColors.of(
                                        context,
                                      ).cardBackground,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: AppColors.of(context).border,
                                        ),
                                      ),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.visibility_outlined,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text('عرض'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                              ),
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
                                                color: AppColors.of(
                                                  context,
                                                ).error,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'حذف',
                                                style: TextStyle(
                                                  color: AppColors.of(
                                                    context,
                                                  ).error,
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
