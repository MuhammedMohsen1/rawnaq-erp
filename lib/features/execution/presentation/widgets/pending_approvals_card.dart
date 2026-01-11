import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/execution_models.dart';

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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions, color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              Text(
                'طلبات الدفعات المعلقة (${pendingRequests.length})',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pendingRequests.map((request) => _PendingRequestItem(
                request: request,
                onApprove: () => onApprove(request.id),
                onReject: () => _showRejectDialog(context, request.id),
              )),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String requestId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض طلب الدفعة'),
        content: TextField(
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
              backgroundColor: AppColors.error,
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
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.phaseName,
                  style: AppTextStyles.tableCellBold,
                ),
                const SizedBox(height: 4),
                Text(
                  'مقدم من: ${request.requestedByName}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'التاريخ: ${dateFormat.format(request.createdAt)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${request.requestedAmount.toStringAsFixed(3)} د.ك',
                style: AppTextStyles.tableCellBold.copyWith(
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, color: AppColors.error),
                    tooltip: 'رفض',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, color: AppColors.success),
                    tooltip: 'قبول',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.success.withValues(alpha: 0.1),
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
