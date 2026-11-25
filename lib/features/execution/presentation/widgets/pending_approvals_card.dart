import 'package:rawnaq/core/utils/arabic_number_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/execution_models.dart';
import 'transaction_attachments.dart';

class PendingApprovalsCard extends StatelessWidget {
  final List<InstallmentRequestModel> pendingRequests;
  final Function(String requestId) onApprove;
  final Function(String requestId, String reason) onReject;

  const PendingApprovalsCard({
    super.key,
    required this.pendingRequests,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.of(context).warning.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pending_actions,
                color: AppColors.of(context).warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'طلبات بنود جدول الدفعات المعلقة (${pendingRequests.length})',
                style: AppTextStyles.of(
                  context,
                ).sectionTitle.copyWith(color: AppColors.of(context).warning),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pendingRequests.map(
            (request) => _PendingRequestItem(
              request: request,
              onApprove: () => onApprove(request.id),
              onReject: () => _showRejectDialog(context, request.id),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String requestId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض طلب بند جدول الدفعات'),
        content: TextField(
          inputFormatters: const [ArabicNumberInputFormatter()],
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'سبب الرفض',
            hintText: 'أدخل سبب رفض الطلب',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Navigator.of(context).pop();
                onReject(requestId, reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.of(context).error,
            ),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }
}

class _PendingRequestItem extends StatelessWidget {
  final InstallmentRequestModel request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingRequestItem({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.phaseName,
                  style: AppTextStyles.of(context).tableCellBold,
                ),
                const SizedBox(height: 4),
                Text(
                  'مقدم من: ${request.requestedByName}',
                  style: AppTextStyles.of(context).bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'التاريخ: ${dateFormat.format(request.createdAt)}',
                  style: AppTextStyles.of(context).bodySmall,
                ),
                if (request.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TransactionAttachments(
                    attachments: request.attachments,
                    compact: false,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${request.requestedAmount.toStringAsFixed(3)} د.ك',
                style: AppTextStyles.of(
                  context,
                ).tableCellBold.copyWith(color: AppColors.of(context).success),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onReject,
                    icon: Icon(Icons.close, color: AppColors.of(context).error),
                    tooltip: 'رفض',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.of(
                        context,
                      ).error.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onApprove,
                    icon: Icon(
                      Icons.check,
                      color: AppColors.of(context).success,
                    ),
                    tooltip: 'قبول',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.of(
                        context,
                      ).success.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
