import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/execution_models.dart';

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
          // Header with totals
          _buildHeader(),
          const Divider(height: 1, color: AppColors.border),
          // Table
          _buildTable(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isAdminOrManager)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          // Summary row
          Row(
            children: [
              if (isAdminOrManager) ...[
                _buildSummaryItem(
                  label: 'إجمالي السعر',
                  value: totalPrice,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 32),
              ],
              _buildSummaryItem(
                label: 'إجمالي التكلفة',
                value: totalCost,
                color: AppColors.textPrimary,
              ),
              if (isAdminOrManager) ...[
                const SizedBox(width: 32),
                _buildSummaryItem(
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

  Widget _buildSummaryItem({
    required String label,
    required double value,
    required Color color,
  }) {
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

  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: isAdminOrManager
            ? const {
                0: FlexColumnWidth(2), // Phase name
                1: FlexColumnWidth(1), // Percentage
                2: FlexColumnWidth(1.5), // Price
                3: FlexColumnWidth(1.5), // Cost
                4: FlexColumnWidth(1.5), // Status
                5: FlexColumnWidth(1), // Action
              }
            : const {
                0: FlexColumnWidth(2), // Phase name
                1: FlexColumnWidth(1), // Percentage
                2: FlexColumnWidth(1.5), // Cost
                3: FlexColumnWidth(1.5), // Status
              },
        children: [
          // Header row
          _buildHeaderRow(),
          // Data rows
          ...paymentSchedule.map((phase) => _buildDataRow(phase)),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    final headers = isAdminOrManager
        ? ['الدفعة', 'النسبة', 'السعر', 'التكلفة', 'الحالة', 'إجراء']
        : ['الدفعة', 'النسبة', 'التكلفة', 'الحالة'];

    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      children: headers
          .map((header) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  header,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ))
          .toList(),
    );
  }

  TableRow _buildDataRow(PaymentPhaseModel phase) {
    final statusWidget = _buildStatusBadge(phase);
    final actionWidget = _buildActionButton(phase);

    final cells = isAdminOrManager
        ? [
            // Phase name
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                phase.phaseName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Percentage
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${phase.percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            // Price (original amount)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${phase.originalAmount.toStringAsFixed(3)} د.ك',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Cost
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${phase.costAmount.toStringAsFixed(3)} د.ك',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            // Status
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(child: statusWidget),
            ),
            // Action
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(child: actionWidget),
            ),
          ]
        : [
            // Phase name
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                phase.phaseName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Percentage
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${phase.percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            // Cost
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${phase.costAmount.toStringAsFixed(3)} د.ك',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            // Status
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(child: statusWidget),
            ),
          ];

    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      children: cells,
    );
  }

  Widget _buildStatusBadge(PaymentPhaseModel phase) {
    String statusText;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (phase.isCollected) {
      statusText = 'تم التحصيل';
      backgroundColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      icon = Icons.check_circle;
    } else if (phase.isApproved) {
      statusText = 'معتمد';
      backgroundColor = AppColors.info.withValues(alpha: 0.1);
      textColor = AppColors.info;
      icon = Icons.verified;
    } else if (phase.isRequested) {
      statusText = 'قيد الانتظار';
      backgroundColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
      icon = Icons.hourglass_empty;
    } else {
      statusText = 'متاح';
      backgroundColor = AppColors.textSecondary.withValues(alpha: 0.1);
      textColor = AppColors.textSecondary;
      icon = Icons.radio_button_unchecked;
    }

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

  Widget _buildActionButton(PaymentPhaseModel phase) {
    if (!isAdminOrManager) return const SizedBox.shrink();

    // Only show collect/uncollect button for approved installments
    if (!phase.isApproved) {
      return const SizedBox(
        height: 36,
        child: Center(
          child: Text(
            '-',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final isCollected = phase.isCollected;

    return SizedBox(
      height: 36,
      child: TextButton(
        onPressed: () {
          if (onToggleCollected != null) {
            onToggleCollected!(phase.index, phase.requestId, isCollected);
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          backgroundColor: isCollected
              ? AppColors.warning.withValues(alpha: 0.1)
              : AppColors.success.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
