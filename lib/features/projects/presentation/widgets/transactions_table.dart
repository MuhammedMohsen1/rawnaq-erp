import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/entities/transaction_entity.dart' as tx;

/// Table widget displaying transactions
class TransactionsTable extends StatefulWidget {
  final List<TransactionEntity> transactions;
  final Function(TransactionEntity)? onDelete;
  final Function(TransactionEntity)? onUpdate;
  final Function()? onLoadMore;
  final Function()? onAddNew;

  const TransactionsTable({
    super.key,
    required this.transactions,
    this.onDelete,
    this.onUpdate,
    this.onLoadMore,
    this.onAddNew,
  });

  @override
  State<TransactionsTable> createState() => _TransactionsTableState();
}

class _TransactionsTableState extends State<TransactionsTable> {
  final Map<String, TextEditingController> _descriptionControllers = {};
  final Map<String, TextEditingController> _amountControllers = {};
  final Map<String, bool> _editingStates = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(TransactionsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions.length != widget.transactions.length) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    // Dispose old controllers
    for (var controller in _descriptionControllers.values) {
      controller.dispose();
    }
    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    _descriptionControllers.clear();
    _amountControllers.clear();
    _editingStates.clear();

    // Initialize controllers for all transactions
    for (var transaction in widget.transactions) {
      _descriptionControllers[transaction.id] =
          TextEditingController(text: transaction.description);
      _amountControllers[transaction.id] =
          TextEditingController(text: transaction.amount.toStringAsFixed(3));
      // New transactions (empty description) start in edit mode
      _editingStates[transaction.id] = transaction.description.isEmpty;
    }
  }

  @override
  void dispose() {
    for (var controller in _descriptionControllers.values) {
      controller.dispose();
    }
    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEdit(String transactionId) {
    setState(() {
      _editingStates[transactionId] = !_editingStates[transactionId]!;
    });
  }

  void _saveTransaction(String transactionId) {
    final transaction = widget.transactions.firstWhere(
      (t) => t.id == transactionId,
    );
    final description = _descriptionControllers[transactionId]!.text.trim();
    final amount = double.tryParse(_amountControllers[transactionId]!.text) ??
        transaction.amount;

    // Only save if description is not empty
    if (description.isNotEmpty) {
      final updatedTransaction = transaction.copyWith(
        description: description,
        amount: amount,
      );

      widget.onUpdate?.call(updatedTransaction);
      setState(() {
        _editingStates[transactionId] = false;
      });
    }
  }

  void _cancelEdit(String transactionId) {
    final transaction = widget.transactions.firstWhere(
      (t) => t.id == transactionId,
    );
    _descriptionControllers[transactionId]!.text = transaction.description;
    _amountControllers[transactionId]!.text =
        transaction.amount.toStringAsFixed(3);
    setState(() {
      _editingStates[transactionId] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty && widget.onAddNew == null) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'لا توجد معاملات',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Type column (tighter)
                SizedBox(
                  width: 50,
                  child: Text(
                    'النوع',
                    style: AppTextStyles.tableHeader,
                  ),
                ),
                // Description column
                Expanded(
                  flex: 3,
                  child: Text(
                    'الوصف / العنصر',
                    style: AppTextStyles.tableHeader,
                  ),
                ),
                // Date column
                Expanded(
                  flex: 1,
                  child: Text(
                    'التاريخ',
                    style: AppTextStyles.tableHeader,
                  ),
                ),
                // Amount column
                Expanded(
                  flex: 1,
                  child: Text(
                    'المبلغ',
                    style: AppTextStyles.tableHeader,
                  ),
                ),
                // Actions column
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجراءات',
                        style: AppTextStyles.tableHeader,
                      ),
                      if (widget.onAddNew != null)
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: widget.onAddNew,
                          tooltip: 'إضافة مصروف جديد',
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Table rows
          ...widget.transactions.map((transaction) => _buildTransactionRow(
                context,
                transaction,
              )),
          // Load more button
          if (widget.onLoadMore != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Center(
                child: TextButton(
                  onPressed: widget.onLoadMore,
                  child: Text(
                    'تحميل المزيد من المعاملات',
                    style: AppTextStyles.link,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy', 'ar');
    final isDeposit = transaction.type == tx.TransactionType.deposit;
    final amountColor = isDeposit ? AppColors.success : AppColors.error;
    final amountPrefix = isDeposit ? '+' : '-';
    final isEditing = _editingStates[transaction.id] ?? false;
    final canEdit = !transaction.metadata.isLocked;

    // Initialize controllers if not exists (for new transactions)
    if (!_descriptionControllers.containsKey(transaction.id)) {
      _descriptionControllers[transaction.id] =
          TextEditingController(text: transaction.description);
      _amountControllers[transaction.id] =
          TextEditingController(text: transaction.amount.toStringAsFixed(3));
      // New transactions (empty description) start in edit mode
      _editingStates[transaction.id] = transaction.description.isEmpty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Type column with icon (tighter)
          SizedBox(
            width: 50,
            child: Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              color: amountColor,
              size: 24,
            ),
          ),
          // Description column (editable)
          Expanded(
            flex: 3,
            child: isEditing
                ? TextField(
                    controller: _descriptionControllers[transaction.id],
                    style: AppTextStyles.tableCellBold,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      // Focus on amount field when done on description
                      FocusScope.of(context).nextFocus();
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  )
                : Text(
                    transaction.description,
                    style: AppTextStyles.tableCellBold,
                  ),
          ),
          // Date column
          Expanded(
            flex: 1,
            child: Tooltip(
              message: DateFormat('dd MMM yyyy, hh:mm a', 'ar')
                  .format(transaction.date),
              waitDuration: const Duration(milliseconds: 500),
              child: GestureDetector(
                onLongPress: () {
                  // Show time on long press (mobile)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        DateFormat('dd MMM yyyy, hh:mm a', 'ar')
                            .format(transaction.date),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  dateFormat.format(transaction.date),
                  style: AppTextStyles.tableCell,
                ),
              ),
            ),
          ),
          // Amount column (editable)
          Expanded(
            flex: 1,
            child: isEditing
                ? TextField(
                    controller: _amountControllers[transaction.id],
                    style: AppTextStyles.tableCellBold.copyWith(
                      color: amountColor,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      // Auto-save when done is pressed on mobile/tablet
                      if (ResponsiveLayout.isMobile(context) ||
                          ResponsiveLayout.isTablet(context)) {
                        _saveTransaction(transaction.id);
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  )
                : _buildAmountWithSmallDecimal(
                    transaction.amount,
                    amountPrefix,
                    amountColor,
                  ),
          ),
          // Actions column
          Expanded(
            flex: 1,
            child: transaction.metadata.isLocked
                ? Icon(
                    Icons.lock,
                    color: AppColors.textMuted,
                    size: 20,
                  )
                : isEditing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check,
                              color: AppColors.success,
                              size: 22,
                            ),
                            onPressed: () => _saveTransaction(transaction.id),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.error,
                              size: 22,
                            ),
                            onPressed: () => _cancelEdit(transaction.id),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (canEdit)
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.info,
                                size: 22,
                              ),
                              onPressed: () => _toggleEdit(transaction.id),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          if (canEdit) const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 22,
                            ),
                            onPressed: widget.onDelete != null
                                ? () => widget.onDelete!(transaction)
                                : null,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountWithSmallDecimal(
    double amount,
    String prefix,
    Color color,
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
        style: AppTextStyles.tableCellBold.copyWith(
          color: color,
        ),
        children: [
          TextSpan(text: '$prefix$integerPart.'),
          TextSpan(
            text: decimalPart,
            style: AppTextStyles.tableCellBold.copyWith(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
