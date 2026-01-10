import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../financial/domain/entities/transaction_entity.dart';

/// Dialog for confirming transaction deletion
class DeleteTransactionDialog extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onConfirm;

  const DeleteTransactionDialog({
    super.key,
    required this.transaction,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: const Text('حذف المعاملة'),
      content: Text(
        'هل أنت متأكد من حذف "${transaction.description}"؟',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text(
            'حذف',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }

  /// Show the dialog
  static Future<void> show(
    BuildContext context, {
    required TransactionEntity transaction,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DeleteTransactionDialog(
        transaction: transaction,
        onConfirm: onConfirm,
      ),
    );
  }
}
