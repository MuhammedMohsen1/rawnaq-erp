import 'package:flutter/material.dart';
import '../../../financial/domain/entities/project_financial_summary.dart';
import 'financial_summary_card.dart';

/// Row of financial summary cards showing key metrics
class FinancialSummaryCardsRow extends StatelessWidget {
  final ProjectFinancialSummary financialSummary;

  const FinancialSummaryCardsRow({
    super.key,
    required this.financialSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FinancialSummaryCard(
            type: FinancialSummaryCardType.totalReceived,
            amount: financialSummary.totalReceived,
            currency: '\$',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FinancialSummaryCard(
            type: FinancialSummaryCardType.totalExpenses,
            amount: financialSummary.totalExpenses,
            currency: '\$',
            subtitle: '3 موافقات معلقة',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FinancialSummaryCard(
            type: FinancialSummaryCardType.netCashFlow,
            amount: financialSummary.netCashFlow,
            currency: '\$',
            budgetPercentage: financialSummary.budgetPercentage,
          ),
        ),
      ],
    );
  }
}
