import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/enums/transaction_type.dart';

class CashFlowSummaryCards extends StatelessWidget {
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final double budgetPercentage;
  final BudgetWarningLevel budgetWarningLevel;

  const CashFlowSummaryCards({
    super.key,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.budgetPercentage,
    required this.budgetWarningLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Total Received Card
        Expanded(
          child: _SummaryCard(
            title: 'إجمالي المستلم',
            value: totalReceived,
            icon: Icons.arrow_downward,
            iconBackgroundColor: AppColors.success.withValues(alpha: 0.1),
            iconColor: AppColors.success,
            valueColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        // Total Expenses Card
        Expanded(
          child: _SummaryCard(
            title: 'إجمالي المصروفات',
            value: totalExpenses,
            icon: Icons.arrow_upward,
            iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
            iconColor: AppColors.error,
            valueColor: AppColors.error,
            showNegative: true,
          ),
        ),
        const SizedBox(width: 16),
        // Net Cash Flow Card with Budget Progress
        Expanded(
          child: _NetCashFlowCard(
            netCashFlow: netCashFlow,
            budgetPercentage: budgetPercentage,
            budgetWarningLevel: budgetWarningLevel,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color valueColor;
  final bool showNegative;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.valueColor,
    this.showNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = showNegative ? -value : value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${displayValue.toStringAsFixed(3)} د.ك',
                  style: AppTextStyles.statNumber.copyWith(
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetCashFlowCard extends StatelessWidget {
  final double netCashFlow;
  final double budgetPercentage;
  final BudgetWarningLevel budgetWarningLevel;

  const _NetCashFlowCard({
    required this.netCashFlow,
    required this.budgetPercentage,
    required this.budgetWarningLevel,
  });

  Color get _progressColor {
    switch (budgetWarningLevel) {
      case BudgetWarningLevel.normal:
        return AppColors.success;
      case BudgetWarningLevel.warning:
        return AppColors.warning;
      case BudgetWarningLevel.danger:
        return Colors.orange;
      case BudgetWarningLevel.exceeded:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = budgetPercentage.clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'صافي التدفق النقدي',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${netCashFlow.toStringAsFixed(3)} د.ك',
            style: AppTextStyles.statNumber.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Budget progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${budgetPercentage.toStringAsFixed(0)}% المتبقي من الميزانية',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _progressColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clampedPercentage / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
