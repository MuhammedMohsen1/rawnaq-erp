import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/project_financial_overview_model.dart';
import '../cubit/project_financial_overview_cubit.dart';
import '../widgets/financial_formatters.dart';

class ProjectFinancialOverviewPage extends StatelessWidget {
  final String projectId;
  const ProjectFinancialOverviewPage({super.key, required this.projectId});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ProjectFinancialOverviewCubit()..load(projectId),
    child: Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body:
          BlocBuilder<
            ProjectFinancialOverviewCubit,
            ProjectFinancialOverviewState
          >(
            builder: (context, state) => switch (state) {
              ProjectFinancialOverviewLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              ProjectFinancialOverviewFailure(:final message) => Center(
                child: Text(message),
              ),
              ProjectFinancialOverviewLoaded(:final overview) =>
                _OverviewContent(overview: overview),
            },
          ),
    ),
  );
}

class _OverviewContent extends StatelessWidget {
  final ProjectFinancialOverviewModel overview;
  const _OverviewContent({required this.overview});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(overview.projectName, style: AppTextStyles.pageTitle),
        const SizedBox(height: 6),
        Text(
          '${overview.projectType == 'DESIGN' ? 'تصميم' : 'تنفيذ'} • '
          '${overview.clientName ?? 'عميل غير محدد'} • ${overview.status}',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 20),
        _AnalyticsGrid(overview: overview),
        const SizedBox(height: 20),
        _CashFlowChart(transactions: overview.transactions),
        const SizedBox(height: 20),
        _TransactionsPanel(transactions: overview.transactions),
      ],
    ),
  );
}

class _AnalyticsGrid extends StatelessWidget {
  final ProjectFinancialOverviewModel overview;
  const _AnalyticsGrid({required this.overview});
  @override
  Widget build(BuildContext context) {
    final items = [
      ('قيمة العقد', overview.totalContractValue),
      ('التكلفة المتوقعة', overview.totalCost),
      ('الربح المتوقع', overview.expectedProfit),
      ('المحصل', overview.totalReceived),
      ('المصروفات', overview.totalExpenses),
      ('صافي التدفق النقدي', overview.netCashFlow),
      ('المتبقي', overview.remainingBudget),
      ('استخدام الميزانية', overview.budgetUsagePercentage),
    ];
    return LayoutBuilder(
      builder: (_, c) {
        final width = c.maxWidth < 700 ? c.maxWidth : (c.maxWidth - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              Container(
                width: width,
                padding: const EdgeInsets.all(16),
                decoration: _panelDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1, style: AppTextStyles.caption),
                    const SizedBox(height: 6),
                    Text(
                      item.$1 == 'استخدام الميزانية'
                          ? '${item.$2.toStringAsFixed(1)}%'
                          : formatKwd(item.$2),
                      style: AppTextStyles.h6,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CashFlowChart extends StatelessWidget {
  final List<ProjectFinancialTransactionModel> transactions;
  const _CashFlowChart({required this.transactions});
  @override
  Widget build(BuildContext context) {
    final dated = transactions.where((item) => item.date != null).toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));
    return Container(
      height: 340,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: dated.isEmpty
          ? const Center(child: Text('لا توجد معاملات مؤرخة لعرضها'))
          : SfCartesianChart(
              tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: DateTimeAxis(dateFormat: DateFormat('yyyy/MM/dd')),
              series:
                  <CartesianSeries<ProjectFinancialTransactionModel, DateTime>>[
                    SplineAreaSeries(
                      dataSource: dated
                          .where((item) => item.type == 'expense')
                          .toList(),
                      xValueMapper: (item, _) => item.date!,
                      yValueMapper: (item, _) => item.amount,
                      color: const Color(0xffef4444),
                      opacity: 0.22,
                      borderColor: const Color(0xffef4444),
                      borderWidth: 2,
                      splineType: SplineType.monotonic,
                      enableTooltip: true,
                    ),
                    SplineAreaSeries(
                      dataSource: dated
                          .where((item) => item.type == 'income')
                          .toList(),
                      xValueMapper: (item, _) => item.date!,
                      yValueMapper: (item, _) => item.amount,
                      color: const Color(0xff22c55e),
                      opacity: 0.28,
                      borderColor: const Color(0xff22c55e),
                      borderWidth: 2,
                      splineType: SplineType.monotonic,
                      enableTooltip: true,
                      markerSettings: const MarkerSettings(isVisible: true),
                    ),
                  ],
            ),
    );
  }
}

class _TransactionsPanel extends StatelessWidget {
  final List<ProjectFinancialTransactionModel> transactions;
  const _TransactionsPanel({required this.transactions});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _panelDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('المعاملات المالية', style: AppTextStyles.h6),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const Text('لا توجد معاملات مالية')
        else
          for (final item in transactions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                item.type == 'income' ? Icons.trending_up : Icons.trending_down,
                color: item.type == 'income'
                    ? AppColors.success
                    : AppColors.error,
              ),
              title: Text(item.description),
              subtitle: Text(
                item.isUndated || item.date == null
                    ? 'غير مؤرخ'
                    : DateFormat('yyyy/MM/dd').format(item.date!),
              ),
              trailing: Text(formatKwd(item.amount)),
            ),
      ],
    ),
  );
}

BoxDecoration _panelDecoration() => BoxDecoration(
  color: AppColors.cardBackground,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: AppColors.border),
);
