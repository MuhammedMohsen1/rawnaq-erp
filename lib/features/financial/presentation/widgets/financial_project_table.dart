import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../data/models/financial_summary_model.dart';
import 'financial_formatters.dart';

class FinancialProjectTable extends StatelessWidget {
  final List<FinancialProjectModel> projects;

  const FinancialProjectTable({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const _EmptyProjectsState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return _ProjectCardList(projects: projects);
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.tableHeader),
                dataRowMinHeight: 58,
                dataRowMaxHeight: 72,
                headingTextStyle: AppTextStyles.tableHeader,
                dataTextStyle: AppTextStyles.tableCell,
                columns: const [
                  DataColumn(label: Text('المشروع')),
                  DataColumn(label: Text('الحالة')),
                  DataColumn(label: Text('قيمة العقد'), numeric: true),
                  DataColumn(label: Text('المحصل'), numeric: true),
                  DataColumn(label: Text('المصروفات'), numeric: true),
                  DataColumn(label: Text('المتبقي'), numeric: true),
                  DataColumn(label: Text('استخدام الميزانية'), numeric: true),
                  DataColumn(label: Text('')),
                ],
                rows: [
                  for (final project in projects)
                    DataRow(
                      cells: [
                        DataCell(_ProjectName(project: project)),
                        DataCell(_StatusBadge(status: project.status)),
                        DataCell(Text(formatKwd(project.totalContractValue))),
                        DataCell(Text(formatKwd(project.totalReceived))),
                        DataCell(Text(formatKwd(project.totalExpenses))),
                        DataCell(
                          Text(
                            formatKwd(project.remainingBudget),
                            style: TextStyle(
                              color: project.remainingBudget >= 0
                                  ? AppColors.textSecondary
                                  : AppColors.error,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(formatPercent(project.budgetUsagePercentage)),
                        ),
                        DataCell(_RowActions(project: project)),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProjectCardList extends StatelessWidget {
  final List<FinancialProjectModel> projects;

  const _ProjectCardList({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < projects.length; index++) ...[
          _MobileProjectTile(project: projects[index]),
          if (index != projects.length - 1)
            const Divider(height: 1, color: AppColors.border),
        ],
      ],
    );
  }
}

class _MobileProjectTile extends StatelessWidget {
  final FinancialProjectModel project;

  const _MobileProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _ProjectName(project: project)),
              _StatusBadge(status: project.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _MiniMetric(
                label: 'العقد',
                value: formatKwd(project.totalContractValue),
              ),
              _MiniMetric(
                label: 'المحصل',
                value: formatKwd(project.totalReceived),
              ),
              _MiniMetric(
                label: 'المصروف',
                value: formatKwd(project.totalExpenses),
              ),
              _MiniMetric(
                label: 'المتبقي',
                value: formatKwd(project.remainingBudget),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _BudgetUsageBar(value: project.budgetUsagePercentage),
          const SizedBox(height: 12),
          _RowActions(project: project),
        ],
      ),
    );
  }
}

class _ProjectName extends StatelessWidget {
  final FinancialProjectModel project;

  const _ProjectName({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          project.projectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.tableCellBold,
        ),
        if ((project.clientName ?? '').isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            project.clientName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'COMPLETED';
    final color = isCompleted ? AppColors.success : AppColors.info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        formatProjectStatus(status),
        style: AppTextStyles.statusBadge.copyWith(color: color),
      ),
    );
  }
}

class _BudgetUsageBar extends StatelessWidget {
  final double value;

  const _BudgetUsageBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100).toDouble();
    final color = value >= 100
        ? AppColors.error
        : value >= 85
        ? AppColors.warning
        : AppColors.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'استخدام الميزانية ${formatPercent(value)}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clamped / 100,
            minHeight: 7,
            backgroundColor: AppColors.progressBackground,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.tableCellBold),
        ],
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  final FinancialProjectModel project;

  const _RowActions({required this.project});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'فتح التنفيذ',
          child: IconButton(
            icon: const Icon(Icons.open_in_new, size: 20),
            color: AppColors.primary,
            onPressed: () =>
                context.push(AppRoutes.execution(project.projectId)),
          ),
        ),
        Tooltip(
          message: 'تفاصيل المشروع',
          child: IconButton(
            icon: const Icon(Icons.folder_open_outlined, size: 20),
            color: AppColors.textSecondary,
            onPressed: () =>
                context.push(AppRoutes.projectDetails(project.projectId)),
          ),
        ),
      ],
    );
  }
}

class _EmptyProjectsState extends StatelessWidget {
  const _EmptyProjectsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.textMuted,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text('لا توجد مشاريع مالية مطابقة', style: AppTextStyles.h6),
          const SizedBox(height: 6),
          Text(
            'جرب تغيير البحث أو راجع مشاريع التنفيذ والمكتملة.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
