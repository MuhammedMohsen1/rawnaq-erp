import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/execution_models.dart';

class InstallmentsHeader extends StatelessWidget {
  final bool isAdminOrManager;
  final double profitPercentage;
  final double totalPrice;
  final double totalCost;
  final double totalProfit;

  const InstallmentsHeader({
    super.key,
    required this.isAdminOrManager,
    required this.profitPercentage,
    required this.totalPrice,
    required this.totalCost,
    required this.totalProfit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جدول الدفعات',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              if (isAdminOrManager)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'الربح: ${profitPercentage.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (isAdminOrManager) ...[
                InstallmentsSummaryItem(
                  label: 'إجمالي السعر',
                  value: totalPrice,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 32),
              ],
              InstallmentsSummaryItem(
                label: 'إجمالي التكلفة',
                value: totalCost,
                color: AppColors.textPrimary,
              ),
              if (isAdminOrManager) ...[
                const SizedBox(width: 32),
                InstallmentsSummaryItem(
                  label: 'الربح',
                  value: totalProfit,
                  color: AppColors.success,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class InstallmentsSummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const InstallmentsSummaryItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(3)} د.ك',
          style: AppTextStyles.h4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class InstallmentsStatusBadge extends StatelessWidget {
  final PaymentPhaseModel phase;

  const InstallmentsStatusBadge({super.key, required this.phase});

  @override
  Widget build(BuildContext context) {
    final (statusText, backgroundColor, textColor, icon) = switch (phase) {
      PaymentPhaseModel(isCollected: true) => (
        'تم التحصيل',
        AppColors.success.withValues(alpha: 0.1),
        AppColors.success,
        Icons.check_circle,
      ),
      PaymentPhaseModel(isApproved: true) => (
        'معتمد',
        AppColors.info.withValues(alpha: 0.1),
        AppColors.info,
        Icons.verified,
      ),
      PaymentPhaseModel(isRequested: true) => (
        'قيد الانتظار',
        AppColors.warning.withValues(alpha: 0.1),
        AppColors.warning,
        Icons.hourglass_empty,
      ),
      _ => (
        'متاح',
        AppColors.textSecondary.withValues(alpha: 0.1),
        AppColors.textSecondary,
        Icons.radio_button_unchecked,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: AppTextStyles.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class InstallmentsActionButton extends StatelessWidget {
  final PaymentPhaseModel phase;
  final bool isAdminOrManager;
  final ValueChanged<int>? onToggleCollected;

  const InstallmentsActionButton({
    super.key,
    required this.phase,
    required this.isAdminOrManager,
    required this.onToggleCollected,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAdminOrManager) return const SizedBox.shrink();
    if (!phase.isApproved) {
      return const SizedBox(
        height: 36,
        child: Center(
          child: Text('-', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final isCollected = phase.isCollected;
    return SizedBox(
      height: 36,
      child: TextButton(
        onPressed: onToggleCollected == null
            ? null
            : () => onToggleCollected!(phase.index),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          backgroundColor: isCollected
              ? AppColors.warning.withValues(alpha: 0.1)
              : AppColors.success.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          isCollected ? 'إلغاء' : 'تحصيل',
          style: AppTextStyles.bodySmall.copyWith(
            color: isCollected ? AppColors.warning : AppColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
