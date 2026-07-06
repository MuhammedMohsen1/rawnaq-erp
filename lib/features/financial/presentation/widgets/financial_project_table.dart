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

          return _PinnedFinancialProjectTable(
            projects: projects,
            minWidth: constraints.maxWidth,
          );
        },
      ),
    );
  }
}

class _PinnedFinancialProjectTable extends StatelessWidget {
  final List<FinancialProjectModel> projects;
  final double minWidth;

  const _PinnedFinancialProjectTable({
    required this.projects,
    required this.minWidth,
  });

  static const Map<int, TableColumnWidth> _columnWidths = {
    0: FixedColumnWidth(250),
    1: FixedColumnWidth(140),
    2: FixedColumnWidth(140),
    3: FixedColumnWidth(130),
    4: FixedColumnWidth(130),
    5: FixedColumnWidth(130),
    6: FixedColumnWidth(130),
    7: FixedColumnWidth(130),
    8: FixedColumnWidth(140),
  };

  static const List<String> _headers = [
    'المشروع',
    'الحالة',
    'نوع المشروع',
    'قيمة العقد',
    'المحصل',
    'المصروفات',
    'الربح',
    'نسبة الربح',
    '',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderTable(),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            SizedBox(
              height: _bodyHeight,
              child: Scrollbar(
                thumbVisibility: projects.length > 5,
                child: SingleChildScrollView(child: _buildBodyTable()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _bodyHeight {
    final estimatedHeight = (projects.length * 72.0).clamp(0, 420).toDouble();
    return estimatedHeight < 220 ? estimatedHeight : 420;
  }

  Widget _buildHeaderTable() {
    return Table(
      columnWidths: _columnWidths,
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppColors.tableHeader),
          children: [
            for (int index = 0; index < _headers.length; index++)
              _HeaderCell(
                label: _headers[index],
                numeric: index >= 3 && index <= 7,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyTable() {
    return Table(
      columnWidths: _columnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (int index = 0; index < projects.length; index++)
          TableRow(
            decoration: BoxDecoration(
              border: index == projects.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            children: _buildRowCells(projects[index]),
          ),
      ],
    );
  }

  List<Widget> _buildRowCells(FinancialProjectModel project) {
    final profit = project.totalReceived - project.totalExpenses;
    final profitPercentage = project.totalExpenses > 0
        ? (profit / project.totalExpenses) * 100
        : 0.0;

    return [
      _BodyCell(
        alignment: Alignment.centerRight,
        child: _ProjectName(project: project),
      ),
      _BodyCell(
        alignment: Alignment.centerRight,
        child: _StatusBadge(
          status: project.status,
          projectType: project.projectType,
        ),
      ),
      _BodyCell(
        alignment: Alignment.centerRight,
        child: _ProjectTypeBadge(label: project.projectType),
      ),
      _BodyCell(
        alignment: Alignment.centerLeft,
        child: Text(
          formatKwd(project.totalContractValue),
          style: AppTextStyles.tableCell,
        ),
      ),
      _BodyCell(
        alignment: Alignment.centerLeft,
        child: Text(
          formatKwd(project.totalReceived),
          style: AppTextStyles.tableCell,
        ),
      ),
      _BodyCell(
        alignment: Alignment.centerLeft,
        child: Text(
          formatKwd(project.totalExpenses),
          style: AppTextStyles.tableCell,
        ),
      ),
      _BodyCell(
        alignment: Alignment.centerLeft,
        child: Text(
          formatKwd(profit),
          style: AppTextStyles.tableCell.copyWith(
            color: profit >= 0 ? AppColors.success : AppColors.error,
          ),
        ),
      ),
      _BodyCell(
        alignment: Alignment.center,
        child: Text(
          formatPercent(profitPercentage),
          style: AppTextStyles.tableCell.copyWith(
            color: profit >= 0 ? AppColors.success : AppColors.error,
          ),
        ),
      ),
      _BodyCell(
        alignment: Alignment.center,
        child: _RowActions(project: project),
      ),
    ];
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final bool numeric;

  const _HeaderCell({required this.label, this.numeric = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: numeric ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(label, style: AppTextStyles.tableHeader),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final Widget child;
  final Alignment alignment;

  const _BodyCell({required this.child, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      alignment: alignment,
      child: child,
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
    final profit = project.totalReceived - project.totalExpenses;
    final profitPercentage = project.totalExpenses > 0
        ? (profit / project.totalExpenses) * 100
        : 0.0;

    return InkWell(
      onTap: () =>
          context.push(AppRoutes.projectFinancialOverview(project.projectId)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _ProjectName(project: project)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusBadge(
                      status: project.status,
                      projectType: project.projectType,
                    ),
                    _ProjectTypeBadge(label: project.projectType),
                  ],
                ),
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
                  label: 'الربح',
                  value: formatKwd(profit),
                  valueColor: profit >= 0
                      ? AppColors.success
                      : AppColors.error,
                ),
                _MiniMetric(
                  label: 'نسبة الربح',
                  value: formatPercent(profitPercentage),
                  valueColor: profit >= 0
                      ? AppColors.success
                      : AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RowActions(project: project),
          ],
        ),
      ),
    );
  }
}

class _ProjectName extends StatelessWidget {
  final FinancialProjectModel project;

  const _ProjectName({required this.project});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.push(AppRoutes.projectFinancialOverview(project.projectId)),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              project.projectName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tableCellBold.copyWith(
                color: AppColors.primary,
              ),
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
        ),
      ),
    );
  }
}

class _ProjectTypeBadge extends StatelessWidget {
  final String? label;

  const _ProjectTypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final projectTypeLabel = formatProjectType(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        projectTypeLabel,
        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String? projectType;

  const _StatusBadge({required this.status, this.projectType});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'COMPLETED' => AppColors.success,
      'PENDING_SIGNATURE' => AppColors.warning,
      'CANCELLED' => AppColors.error,
      'DRAFT' => AppColors.textMuted,
      _ => AppColors.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        formatProjectStatus(status, projectType: projectType),
        style: AppTextStyles.statusBadge.copyWith(color: color),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MiniMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.tableCellBold.copyWith(color: valueColor),
          ),
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
          message: 'كشف الحساب المالي',
          child: IconButton(
            icon: const Icon(Icons.receipt_long_outlined, size: 20),
            color: AppColors.success,
            onPressed: () => context.push(
              AppRoutes.projectFinancialOverview(project.projectId),
            ),
          ),
        ),
        if (!project.isDesignProject)
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
