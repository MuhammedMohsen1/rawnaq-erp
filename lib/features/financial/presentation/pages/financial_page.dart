import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../cubit/financial_cubit.dart';
import '../cubit/financial_state.dart';
import '../widgets/financial_kpi_grid.dart';
import '../widgets/financial_project_table.dart';
import '../widgets/financial_toolbar.dart';

class FinancialPage extends StatelessWidget {
  const FinancialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<FinancialCubit>()..loadSummary(period: 'MONTH'),
      child: const _FinancialPageView(),
    );
  }
}

class _FinancialPageView extends StatelessWidget {
  const _FinancialPageView();

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _FinancialLayout(padding: 16),
      tablet: const _FinancialLayout(padding: 24),
      desktop: const _FinancialLayout(padding: 32),
    );
  }
}

class _FinancialLayout extends StatelessWidget {
  final double padding;

  const _FinancialLayout({required this.padding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: BlocBuilder<FinancialCubit, FinancialState>(
        builder: (context, state) {
          return switch (state) {
            FinancialInitial() || FinancialLoading() => const _LoadingView(),
            FinancialFailure(:final message) => _FailureView(message: message),
            FinancialLoaded() => _LoadedFinancialView(
              state: state,
              padding: padding,
            ),
          };
        },
      ),
    );
  }
}

class _LoadedFinancialView extends StatelessWidget {
  final FinancialLoaded state;
  final double padding;

  const _LoadedFinancialView({required this.state, required this.padding});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FinancialHeader(),
          const SizedBox(height: 20),
          FinancialKpiGrid(totals: state.summary.totals),
          const SizedBox(height: 20),
          _PortfolioHealthStrip(state: state),
          const SizedBox(height: 20),
          FinancialToolbar(
            projectCount: state.filteredProjects.length,
            onSearchChanged: context.read<FinancialCubit>().updateSearchQuery,
            onRefresh: context.read<FinancialCubit>().loadSummary,
            selectedPeriod: state.period,
            selectedProjectType: state.projectType,
            customRange: state.customRange,
            onPeriodChanged: context.read<FinancialCubit>().selectPeriod,
            onProjectTypeChanged: context.read<FinancialCubit>().selectProjectType,
            onCustomRangeChanged: context
                .read<FinancialCubit>()
                .selectCustomRange,
          ),
          if (state.period != null || state.customRange != null) ...[
            const SizedBox(height: 10),
            const Text(
              'تم تطبيق الفترة على المشاريع والقيم المالية المعروضة.',
              style: AppTextStyles.caption,
            ),
          ],
          const SizedBox(height: 14),
          FinancialProjectTable(projects: state.filteredProjects),
        ],
      ),
    );
  }
}

class _FinancialHeader extends StatelessWidget {
  const _FinancialHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المالية', style: AppTextStyles.pageTitle),
        SizedBox(height: 6),
        Text(
          'نظرة مالية على مشاريع التنفيذ والتصميم والمشاريع المكتملة',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

class _PortfolioHealthStrip extends StatelessWidget {
  final FinancialLoaded state;

  const _PortfolioHealthStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final overBudgetCount = state.summary.projects
        .where((project) => project.budgetUsagePercentage >= 100)
        .length;
    final warningCount = state.summary.projects
        .where(
          (project) =>
              project.budgetUsagePercentage >= 85 &&
              project.budgetUsagePercentage < 100,
        )
        .length;
    final healthyCount =
        state.summary.projects.length - overBudgetCount - warningCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final items = [
            _HealthItem(
              label: 'ضمن الميزانية',
              value: healthyCount.toString(),
              color: AppColors.success,
              icon: Icons.check_circle_outline,
            ),
            _HealthItem(
              label: 'قريب من الميزانية',
              value: warningCount.toString(),
              color: AppColors.warning,
              icon: Icons.error_outline,
            ),
            _HealthItem(
              label: 'تجاوز الميزانية',
              value: overBudgetCount.toString(),
              color: AppColors.error,
              icon: Icons.warning_amber_outlined,
            ),
          ];

          if (constraints.maxWidth < 680) {
            return Column(
              children: [
                for (int index = 0; index < items.length; index++) ...[
                  items[index],
                  if (index != items.length - 1)
                    const Divider(height: 24, color: AppColors.border),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (int index = 0; index < items.length; index++) ...[
                Expanded(child: items[index]),
                if (index != items.length - 1) const SizedBox(width: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HealthItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _HealthItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTextStyles.label)),
        Text(value, style: AppTextStyles.h5.copyWith(color: color)),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _FailureView extends StatelessWidget {
  final String message;

  const _FailureView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 42),
            const SizedBox(height: 12),
            const Text('تعذر تحميل البيانات المالية', style: AppTextStyles.h6),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: context.read<FinancialCubit>().loadSummary,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
