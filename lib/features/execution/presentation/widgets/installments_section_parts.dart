import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/execution_models.dart';
import 'transaction_attachments.dart';

class InstallmentsSectionHeader extends StatelessWidget {
  final bool isAdminOrManager;
  final double totalPrice;
  final double totalCost;
  final double totalProfit;
  final double profitPercentage;
  final VoidCallback? onOpenDialog;

  const InstallmentsSectionHeader({
    super.key,
    required this.isAdminOrManager,
    required this.totalPrice,
    required this.totalCost,
    required this.totalProfit,
    required this.profitPercentage,
    this.onOpenDialog,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onOpenDialog != null)
                    IconButton(
                      onPressed: onOpenDialog,
                      icon: const Icon(Icons.open_in_new),
                      tooltip: 'فتح جدول الدفعات',
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

class InstallmentsSectionTable extends StatelessWidget {
  final List<PaymentPhaseModel> paymentSchedule;
  final bool isAdminOrManager;
  final Function(int phaseIndex, String? requestId, bool currentlyCollected)?
  onToggleCollected;
  final void Function(PaymentPhaseModel phase)? onRequestPaymentPhase;

  const InstallmentsSectionTable({
    super.key,
    required this.paymentSchedule,
    required this.isAdminOrManager,
    required this.onToggleCollected,
    this.onRequestPaymentPhase,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: isAdminOrManager
            ? const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.3),
                5: FlexColumnWidth(1),
                6: FlexColumnWidth(1),
              }
            : const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
              },
        children: [
          InstallmentsTableHeader(
            isAdminOrManager: isAdminOrManager,
          ).toTableRow(),
          ...paymentSchedule.map(
            (phase) => InstallmentsTableRow(
              phase: phase,
              isAdminOrManager: isAdminOrManager,
              onToggleCollected: onToggleCollected,
              onRequestPaymentPhase: onRequestPaymentPhase,
            ).toTableRow(),
          ),
        ],
      ),
    );
  }
}

class InstallmentsTableHeader {
  final bool isAdminOrManager;

  const InstallmentsTableHeader({required this.isAdminOrManager});

  TableRow toTableRow() {
    final headers = isAdminOrManager
        ? [
            'بند الجدول',
            'النسبة',
            'السعر',
            'التكلفة',
            'الحالة',
            'التقاط',
            'إجراء',
          ]
        : ['بند الجدول', 'النسبة', 'التكلفة', 'الحالة', 'التقاط', 'إجراء'];

    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      children: headers
          .map(
            (header) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                header,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
          .toList(),
    );
  }
}

class InstallmentsTableRow {
  final PaymentPhaseModel phase;
  final bool isAdminOrManager;
  final Function(int phaseIndex, String? requestId, bool currentlyCollected)?
  onToggleCollected;
  final void Function(PaymentPhaseModel phase)? onRequestPaymentPhase;

  const InstallmentsTableRow({
    required this.phase,
    required this.isAdminOrManager,
    required this.onToggleCollected,
    this.onRequestPaymentPhase,
  });

  TableRow toTableRow() {
    final statusWidget = InstallmentStatusBadge(phase: phase);
    final attachmentsWidget = phase.attachments.isEmpty
        ? const Text('-', style: TextStyle(color: AppColors.textSecondary))
        : TransactionAttachments(attachments: phase.attachments, compact: true);
    final actionWidget = InstallmentActionButton(
      phase: phase,
      isAdminOrManager: isAdminOrManager,
      onToggleCollected: onToggleCollected,
      onRequestPaymentPhase: onRequestPaymentPhase,
    );

    final cells = isAdminOrManager
        ? [
            InstallmentsTableCell(
              child: Text(
                phase.phaseName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            InstallmentsTableCell(
              child: Text(
                '${phase.percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            InstallmentsTableCell(
              child: Text(
                '${phase.originalAmount.toStringAsFixed(3)} د.ك',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            InstallmentsTableCell(
              child: Text(
                '${phase.costAmount.toStringAsFixed(3)} د.ك',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const InstallmentsTableCell(child: Center(child: SizedBox())),
          ]
        : [
            InstallmentsTableCell(
              child: Text(
                phase.phaseName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            InstallmentsTableCell(
              child: Text(
                '${phase.percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            InstallmentsTableCell(
              child: Text(
                '${phase.costAmount.toStringAsFixed(3)} د.ك',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            InstallmentsTableCell(child: Center(child: statusWidget)),
            InstallmentsTableCell(child: Center(child: attachmentsWidget)),
            InstallmentsTableCell(
              padding: const EdgeInsets.all(8),
              child: Center(child: actionWidget),
            ),
          ];

    final rowCells = isAdminOrManager
        ? [
            cells[0],
            cells[1],
            cells[2],
            cells[3],
            InstallmentsTableCell(child: Center(child: statusWidget)),
            InstallmentsTableCell(child: Center(child: attachmentsWidget)),
            InstallmentsTableCell(
              padding: const EdgeInsets.all(8),
              child: Center(child: actionWidget),
            ),
          ]
        : cells;

    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      children: rowCells,
    );
  }
}

class InstallmentsTableCell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const InstallmentsTableCell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) => Padding(padding: padding, child: child);
}

class InstallmentStatusBadge extends StatelessWidget {
  final PaymentPhaseModel phase;

  const InstallmentStatusBadge({super.key, required this.phase});

  @override
  Widget build(BuildContext context) {
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
}

class InstallmentActionButton extends StatelessWidget {
  final PaymentPhaseModel phase;
  final bool isAdminOrManager;
  final Function(int phaseIndex, String? requestId, bool currentlyCollected)?
  onToggleCollected;
  final void Function(PaymentPhaseModel phase)? onRequestPaymentPhase;

  const InstallmentActionButton({
    super.key,
    required this.phase,
    required this.isAdminOrManager,
    required this.onToggleCollected,
    this.onRequestPaymentPhase,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAdminOrManager) {
      if (phase.isRequested || phase.isApproved) {
        return const SizedBox(
          height: 36,
          child: Center(
            child: Text('-', style: TextStyle(color: AppColors.textSecondary)),
          ),
        );
      }
      return SizedBox(
        height: 36,
        child: TextButton.icon(
          onPressed: onRequestPaymentPhase == null
              ? null
              : () => onRequestPaymentPhase!(phase),
          icon: const Icon(Icons.upload_file_outlined, size: 15),
          label: const Text('طلب'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }
    if (!phase.isApproved || !phase.isCollected) {
      return SizedBox(
        height: 36,
        child: TextButton.icon(
          onPressed: onRequestPaymentPhase == null
              ? null
              : () => onRequestPaymentPhase!(phase),
          icon: const Icon(Icons.payments_outlined, size: 15),
          label: const Text('دفع'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            backgroundColor: AppColors.success.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
