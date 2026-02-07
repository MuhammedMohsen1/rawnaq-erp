import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/enums/transaction_type.dart';

class CashFlowSummaryCards extends StatelessWidget {
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final double totalBudget;
  final double totalPrice;
  final double budgetPercentage;
  final BudgetWarningLevel budgetWarningLevel;
  final DateTime? startDate;
  final DateTime? endDate;

  const CashFlowSummaryCards({
    super.key,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.totalBudget,
    required this.totalPrice,
    required this.budgetPercentage,
    required this.budgetWarningLevel,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final isCompact = constraints.maxWidth < 1100;

        final cards = [
          _SummaryCard(
            title: 'إجمالي المستلم',
            value: totalReceived,
            icon: Icons.arrow_downward,
            iconBackgroundColor: AppColors.success.withValues(alpha: 0.1),
            iconColor: AppColors.success,
            valueColor: AppColors.success,
          ),
          _SummaryCard(
            title: 'إجمالي المصروفات',
            value: totalExpenses,
            icon: Icons.arrow_upward,
            iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
            iconColor: AppColors.error,
            valueColor: AppColors.error,
            showNegative: true,
          ),
          _NetCashFlowCard(
            netCashFlow: netCashFlow,
            totalBudget: totalBudget,
            budgetPercentage: budgetPercentage,
            budgetWarningLevel: budgetWarningLevel,
          ),
          _DateProgressCard(startDate: startDate, endDate: endDate),
        ];

        if (isNarrow) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i != cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        if (isCompact) {
          final cardWidth = (constraints.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final card in cards) SizedBox(width: cardWidth, child: card),
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
              const SizedBox(width: 16),
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
        );
      },
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${displayValue.toStringAsFixed(3)} د.ك',
                  style: AppTextStyles.sectionTitle.copyWith(color: valueColor),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 12),
          ),
        ],
      ),
    );
  }
}

class _NetCashFlowCard extends StatelessWidget {
  final double netCashFlow;
  final double budgetPercentage;
  final double totalBudget;
  final BudgetWarningLevel budgetWarningLevel;

  const _NetCashFlowCard({
    required this.netCashFlow,
    required this.budgetPercentage,
    required this.totalBudget,
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
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${netCashFlow.toStringAsFixed(3)} د.ك',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Budget progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${budgetPercentage.toStringAsFixed(0)}% المتبقى من ${totalBudget.toStringAsFixed(0)} د.ك ',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.overline.copyWith(
                    color: _progressColor,
                    fontWeight: FontWeight.w500,
                  ),
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

class _DateProgressCard extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const _DateProgressCard({this.startDate, this.endDate});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM', 'ar');
    final now = DateTime.now();

    final isValidRange =
        startDate != null && endDate != null && !endDate!.isBefore(startDate!);

    int? totalDays;
    int? elapsedDays;
    int? daysLeft;
    double? percent;

    if (isValidRange) {
      totalDays = endDate!.difference(startDate!).inDays;
      if (totalDays <= 0) {
        totalDays = 1;
      }

      final rawElapsed = now.difference(startDate!).inDays;
      elapsedDays = rawElapsed.clamp(0, totalDays).toInt();
      percent = (elapsedDays / totalDays) * 100;

      final rawLeft = endDate!.difference(now).inDays;
      daysLeft = rawLeft < 0 ? 0 : rawLeft;
    }

    final percentValue = percent ?? 0;

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
          Text(
            'تاريخ التسليم',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isValidRange && endDate != null
                ? dateFormat.format(endDate!)
                : 'غير متاح',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (isValidRange) ...[
            Text(
              'التقدم: ${percentValue.toStringAsFixed(0)}% · المتبقي: $daysLeft يوم',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentValue / 100).clamp(0, 1),
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 8,
              ),
            ),
          ] else ...[
            Text(
              'لا توجد بيانات تاريخ البدء أو الانتهاء',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
