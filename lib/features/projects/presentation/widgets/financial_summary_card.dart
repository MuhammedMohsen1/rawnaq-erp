import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Type of financial summary card
enum FinancialSummaryCardType { totalReceived, totalExpenses, netCashFlow }

/// Reusable card widget for financial metrics
class FinancialSummaryCard extends StatelessWidget {
  final FinancialSummaryCardType type;
  final double amount;
  final String currency;
  final String? subtitle;
  final double? budgetPercentage; // For net cash flow card

  const FinancialSummaryCard({
    super.key,
    required this.type,
    required this.amount,
    this.currency = '\$',
    this.subtitle,
    this.budgetPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with dot and title
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getDotColor(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getTitle(),
                style: AppTextStyles.of(context).bodyMedium.copyWith(
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountWithSmallDecimal(context, amount, currency),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (type == FinancialSummaryCardType.totalExpenses &&
                              subtitle != null)
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: AppColors.of(context).warning,
                            ),
                          if (type == FinancialSummaryCardType.totalExpenses &&
                              subtitle != null)
                            const SizedBox(width: 4),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: AppTextStyles.of(context).caption.copyWith(
                                color: AppColors.of(context).textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (type == FinancialSummaryCardType.netCashFlow &&
                        budgetPercentage != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: budgetPercentage! / 100,
                                minHeight: 6,
                                backgroundColor: AppColors.of(
                                  context,
                                ).progressBackground,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.of(context).statusActive,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${budgetPercentage!.toStringAsFixed(0)}% الميزانية المتبقية',
                            style: AppTextStyles.of(context).caption.copyWith(
                              color: AppColors.of(context).textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Icon
              Icon(_getIcon(), size: 48, color: _getIconColor(context)),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case FinancialSummaryCardType.totalReceived:
        return 'إجمالي المستلم';
      case FinancialSummaryCardType.totalExpenses:
        return 'إجمالي المصروفات';
      case FinancialSummaryCardType.netCashFlow:
        return 'سيولة';
    }
  }

  Color _getDotColor(BuildContext context) {
    switch (type) {
      case FinancialSummaryCardType.totalReceived:
        return AppColors.of(context).success;
      case FinancialSummaryCardType.totalExpenses:
        return AppColors.of(context).error;
      case FinancialSummaryCardType.netCashFlow:
        return AppColors.of(context).statusActive;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case FinancialSummaryCardType.totalReceived:
        return Icons.arrow_downward;
      case FinancialSummaryCardType.totalExpenses:
        return Icons.arrow_upward;
      case FinancialSummaryCardType.netCashFlow:
        return Icons.account_balance_wallet;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (type) {
      case FinancialSummaryCardType.totalReceived:
        return AppColors.of(context).success;
      case FinancialSummaryCardType.totalExpenses:
        return AppColors.of(context).error;
      case FinancialSummaryCardType.netCashFlow:
        return AppColors.of(context).statusActive;
    }
  }

  Widget _buildAmountWithSmallDecimal(
    BuildContext context,
    double amount,
    String currency,
  ) {
    // Format with commas for thousands
    final parts = amount.toStringAsFixed(3).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final decimalPart = parts[1];

    return RichText(
      text: TextSpan(
        style: AppTextStyles.of(context).h3.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.of(context).textPrimary,
        ),
        children: [
          TextSpan(text: '$integerPart.'),
          TextSpan(
            text: decimalPart,
            style: AppTextStyles.of(context).h3.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          TextSpan(
            text: ' $currency',
            style: AppTextStyles.of(context).h3.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
