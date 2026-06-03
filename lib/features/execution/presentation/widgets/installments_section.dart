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
  final void Function(PaymentPhaseModel phase)? onRequestPaymentPhase;
  final VoidCallback? onOpenDialog;

  const InstallmentsSection({
    super.key,
    required this.paymentSchedule,
    required this.totalPrice,
    required this.totalCost,
    required this.totalProfit,
    required this.profitPercentage,
    required this.isAdminOrManager,
    this.onToggleCollected,
    this.onRequestPaymentPhase,
    this.onOpenDialog,
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
            onOpenDialog: onOpenDialog,
          ),
          const Divider(height: 1, color: AppColors.border),
          InstallmentsSectionTable(
            paymentSchedule: paymentSchedule,
            isAdminOrManager: isAdminOrManager,
            onToggleCollected: onToggleCollected,
            onRequestPaymentPhase: onRequestPaymentPhase,
          ),
        ],
      ),
    );
  }
}

class PaymentScheduleDialog extends StatelessWidget {
  final List<PaymentPhaseModel> paymentSchedule;
  final double totalPrice;
  final double totalCost;
  final double totalProfit;
  final double profitPercentage;
  final bool isAdminOrManager;
  final Function(int phaseIndex, String? requestId, bool currentlyCollected)?
  onToggleCollected;
  final void Function(PaymentPhaseModel phase)? onRequestPaymentPhase;

  const PaymentScheduleDialog({
    super.key,
    required this.paymentSchedule,
    required this.totalPrice,
    required this.totalCost,
    required this.totalProfit,
    required this.profitPercentage,
    required this.isAdminOrManager,
    this.onToggleCollected,
    this.onRequestPaymentPhase,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120, maxHeight: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  const Expanded(child: SizedBox.shrink()),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),
            InstallmentsSectionHeader(
              isAdminOrManager: isAdminOrManager,
              totalPrice: totalPrice,
              totalCost: totalCost,
              totalProfit: totalProfit,
              profitPercentage: profitPercentage,
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: InstallmentsSectionTable(
                  paymentSchedule: paymentSchedule,
                  isAdminOrManager: isAdminOrManager,
                  onToggleCollected: onToggleCollected,
                  onRequestPaymentPhase: onRequestPaymentPhase,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
