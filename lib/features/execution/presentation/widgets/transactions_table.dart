import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/execution_models.dart';
import '../../domain/enums/transaction_type.dart';
import '../cubit/execution_cubit.dart';

class TransactionsTable extends StatelessWidget {
  final String projectId;
  final List<TransactionModel> transactions;
  final bool isAddingExpense;
  final Map<String, bool> editingTransactions;
  final bool isLoadingMore;
  final bool hasMoreTransactions;
  final bool isSiteEngineer;
  final bool isAdminOrManager;
  final List<PaymentPhaseModel> paymentSchedule;
  final double profitPercentage;
  final VoidCallback onAddExpense;
  final VoidCallback? onRequestInstallment;
  final VoidCallback onLoadMore;

  const TransactionsTable({
    super.key,
    required this.projectId,
    required this.transactions,
    required this.isAddingExpense,
    required this.editingTransactions,
    required this.isLoadingMore,
    required this.hasMoreTransactions,
    required this.isSiteEngineer,
    required this.isAdminOrManager,
    required this.paymentSchedule,
    required this.profitPercentage,
    required this.onAddExpense,
    this.onRequestInstallment,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header with actions
          _TableHeader(
            onAddExpense: onAddExpense,
            onRequestInstallment: onRequestInstallment,
            isSiteEngineer: isSiteEngineer,
          ),
          const Divider(height: 1, color: AppColors.border),
          // Column headers
          _ColumnHeaders(),
          const Divider(height: 1, color: AppColors.border),
          // Add expense row (if adding)
          if (isAddingExpense)
            _AddExpenseRow(
              projectId: projectId,
              onCancel: () => context.read<ExecutionCubit>().cancelAddingExpense(),
            ),
          // Transaction rows
          ...transactions.map((transaction) {
            final isEditing = editingTransactions[transaction.id] ?? false;
            return _TransactionRow(
              projectId: projectId,
              transaction: transaction,
              isEditing: isEditing,
            );
          }),
          // Load more button
          if (hasMoreTransactions)
            _LoadMoreButton(
              isLoading: isLoadingMore,
              onLoadMore: onLoadMore,
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback? onRequestInstallment;
  final bool isSiteEngineer;

  const _TableHeader({
    required this.onAddExpense,
    this.onRequestInstallment,
    required this.isSiteEngineer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onRequestInstallment != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: OutlinedButton.icon(
                onPressed: onRequestInstallment,
                icon: const Icon(Icons.request_page, size: 18),
                label: const Text('طلب دفعة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ElevatedButton.icon(
            onPressed: onAddExpense,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('إضافة مصروف جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.scaffoldBackground,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text('النوع', style: AppTextStyles.tableHeader),
          ),
          Expanded(
            flex: 3,
            child: Text('الوصف / البند', style: AppTextStyles.tableHeader),
          ),
          SizedBox(
            width: 120,
            child: Text('التاريخ', style: AppTextStyles.tableHeader),
          ),
          SizedBox(
            width: 140,
            child: Text(
              'المبلغ',
              style: AppTextStyles.tableHeader,
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'إجراءات',
              style: AppTextStyles.tableHeader,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String projectId;
  final TransactionModel transaction;
  final bool isEditing;

  const _TransactionRow({
    required this.projectId,
    required this.transaction,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing && transaction.isEditable) {
      return _EditableExpenseRow(
        projectId: projectId,
        transaction: transaction,
        onCancel: () => context.read<ExecutionCubit>().cancelEditing(transaction.id),
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // Type icon
          SizedBox(
            width: 60,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isIncome
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.success : AppColors.error,
                size: 18,
              ),
            ),
          ),
          // Description
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.tableCellBold,
                ),
                if (transaction.subDescription != null)
                  Text(
                    transaction.subDescription!,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
          // Date
          SizedBox(
            width: 120,
            child: Text(
              dateFormat.format(transaction.date),
              style: AppTextStyles.tableCell,
            ),
          ),
          // Amount
          SizedBox(
            width: 140,
            child: Text(
              '${isIncome ? '+' : ''}${transaction.amount.toStringAsFixed(3)}',
              style: AppTextStyles.tableCellBold.copyWith(
                color: isIncome ? AppColors.success : AppColors.error,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          // Actions
          SizedBox(
            width: 80,
            child: transaction.isEditable
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () =>
                            context.read<ExecutionCubit>().toggleEditing(transaction.id),
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'تعديل',
                        color: AppColors.textSecondary,
                      ),
                      IconButton(
                        onPressed: () =>
                            _showDeleteConfirmation(context, transaction.id),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        tooltip: 'حذف',
                        color: AppColors.error,
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ExecutionCubit>().deleteExpense(projectId, transactionId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _AddExpenseRow extends StatefulWidget {
  final String projectId;
  final VoidCallback onCancel;

  const _AddExpenseRow({
    required this.projectId,
    required this.onCancel,
  });

  @override
  State<_AddExpenseRow> createState() => _AddExpenseRowState();
}

class _AddExpenseRowState extends State<_AddExpenseRow> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _quantityController = TextEditingController();
  CostType _costType = CostType.total;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitCostController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.success.withValues(alpha: 0.05),
      child: Row(
        children: [
          // Type icon placeholder
          SizedBox(
            width: 60,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: AppColors.error,
                size: 18,
              ),
            ),
          ),
          // Name input
          Expanded(
            flex: 2,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'اسم المصروف',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Cost type dropdown
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<CostType>(
              value: _costType,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: CostType.total, child: Text('إجمالي')),
                DropdownMenuItem(value: CostType.unitBased, child: Text('وحدة')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _costType = value);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Amount or Unit cost + Quantity
          if (_costType == CostType.total)
            SizedBox(
              width: 120,
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'المبلغ',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            )
          else ...[
            SizedBox(
              width: 80,
              child: TextField(
                controller: _unitCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'سعر الوحدة',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('×'),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'الكمية',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close, color: AppColors.error),
                tooltip: 'إلغاء',
              ),
              IconButton(
                onPressed: _isSubmitting ? null : _submitExpense,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check, color: AppColors.success),
                tooltip: 'حفظ',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitExpense() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم المصروف')),
      );
      return;
    }

    double? amount;
    double? unitCost;
    double? quantity;

    if (_costType == CostType.total) {
      amount = double.tryParse(_amountController.text);
      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
        );
        return;
      }
    } else {
      unitCost = double.tryParse(_unitCostController.text);
      quantity = double.tryParse(_quantityController.text);
      if (unitCost == null || quantity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال سعر الوحدة والكمية')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = CreateExpenseDto(
        name: _nameController.text,
        type: 'DAILY',
        costType: _costType == CostType.total ? 'TOTAL' : 'UNIT_BASED',
        amount: amount,
        unitCost: unitCost,
        quantity: quantity,
        date: _selectedDate,
      );

      await context.read<ExecutionCubit>().addExpense(widget.projectId, dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المصروف بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إضافة المصروف: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _EditableExpenseRow extends StatefulWidget {
  final String projectId;
  final TransactionModel transaction;
  final VoidCallback onCancel;

  const _EditableExpenseRow({
    required this.projectId,
    required this.transaction,
    required this.onCancel,
  });

  @override
  State<_EditableExpenseRow> createState() => _EditableExpenseRowState();
}

class _EditableExpenseRowState extends State<_EditableExpenseRow> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _unitCostController;
  late TextEditingController _quantityController;
  late CostType _costType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.transaction.description);
    _costType = widget.transaction.costType ?? CostType.total;

    if (_costType == CostType.total) {
      _amountController = TextEditingController(
        text: widget.transaction.amount.abs().toString(),
      );
      _unitCostController = TextEditingController();
      _quantityController = TextEditingController();
    } else {
      _amountController = TextEditingController();
      _unitCostController = TextEditingController(
        text: widget.transaction.unitCost?.toString() ?? '',
      );
      _quantityController = TextEditingController(
        text: widget.transaction.quantity?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitCostController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          // Type icon
          SizedBox(
            width: 60,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: AppColors.error,
                size: 18,
              ),
            ),
          ),
          // Name input
          Expanded(
            flex: 2,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'اسم المصروف',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Cost type dropdown
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<CostType>(
              value: _costType,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: CostType.total, child: Text('إجمالي')),
                DropdownMenuItem(value: CostType.unitBased, child: Text('وحدة')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _costType = value);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Amount or Unit cost + Quantity
          if (_costType == CostType.total)
            SizedBox(
              width: 120,
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'المبلغ',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            )
          else ...[
            SizedBox(
              width: 80,
              child: TextField(
                controller: _unitCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'سعر الوحدة',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('×'),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'الكمية',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close, color: AppColors.error),
                tooltip: 'إلغاء',
              ),
              IconButton(
                onPressed: _isSubmitting ? null : _submitUpdate,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check, color: AppColors.success),
                tooltip: 'حفظ',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitUpdate() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم المصروف')),
      );
      return;
    }

    double? amount;
    double? unitCost;
    double? quantity;

    if (_costType == CostType.total) {
      amount = double.tryParse(_amountController.text);
      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
        );
        return;
      }
    } else {
      unitCost = double.tryParse(_unitCostController.text);
      quantity = double.tryParse(_quantityController.text);
      if (unitCost == null || quantity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال سعر الوحدة والكمية')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = UpdateExpenseDto(
        name: _nameController.text,
        costType: _costType == CostType.total ? 'TOTAL' : 'UNIT_BASED',
        amount: amount,
        unitCost: unitCost,
        quantity: quantity,
      );

      await context.read<ExecutionCubit>().updateExpense(
            widget.projectId,
            widget.transaction.id,
            dto,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث المصروف بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحديث المصروف: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLoadMore;

  const _LoadMoreButton({
    required this.isLoading,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: onLoadMore,
                child: Text(
                  'تحميل المزيد من المعاملات',
                  style: AppTextStyles.link,
                ),
              ),
      ),
    );
  }
}
