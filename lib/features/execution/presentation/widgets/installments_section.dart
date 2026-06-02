import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/execution_models.dart';
import 'installments_section_parts.dart';

/// InstallmentsSection widget - displays payment schedule with totals
/// Admin/Manager: View full table with price, cost, status and collect/uncollect actions
/// Site Engineer: View cost-only table with status
class InstallmentsSection extends StatelessWidget {
  final List<PaymentPhaseModel> paymentSchedule;
  final double totalPrice;
  final double totalCost;
  final double totalProfit;
  final double profitPercentage;
  final bool isAdminOrManager;
  final Function(int phaseIndex, String? requestId, bool currentlyCollected)?
  onToggleCollected;

  const InstallmentsSection({
    super.key,
    required this.paymentSchedule,
    required this.totalPrice,
    required this.totalCost,
    required this.totalProfit,
    required this.profitPercentage,
    required this.isAdminOrManager,
    this.onToggleCollected,
  });

  @override
  Widget build(BuildContext context) {
    if (paymentSchedule.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InstallmentsSectionHeader(
            isAdminOrManager: isAdminOrManager,
            totalPrice: totalPrice,
            totalCost: totalCost,
            totalProfit: totalProfit,
            profitPercentage: profitPercentage,
          ),
          const Divider(height: 1, color: AppColors.border),
          InstallmentsSectionTable(
            paymentSchedule: paymentSchedule,
            isAdminOrManager: isAdminOrManager,
            onToggleCollected: onToggleCollected,
          ),
        ],
      ),
    );
  }
}
