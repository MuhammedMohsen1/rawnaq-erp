import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

/// Breadcrumb navigation widget for project pages
class ProjectBreadcrumb extends StatelessWidget {
  final String? projectName;

  const ProjectBreadcrumb({super.key, this.projectName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go(AppRoutes.projects),
          child: Text(
            'المشاريع',
            style: AppTextStyles.of(context).bodyMedium.copyWith(
              color: AppColors.of(context).textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_left,
          color: AppColors.of(context).textSecondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          ArabicNumberTransformer.transform(projectName ?? 'مشروع'),
          style: AppTextStyles.of(context).bodyMedium.copyWith(
            color: AppColors.of(context).textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
