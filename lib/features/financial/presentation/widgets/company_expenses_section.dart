import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/financial_summary_model.dart';
import '../cubit/financial_cubit.dart';
import 'financial_formatters.dart';

class CompanyProfitPanel extends StatelessWidget {
  final CompanyProfitModel profit;

  const CompanyProfitPanel({super.key, required this.profit});

  @override
  Widget build(BuildContext context) {
    final netColor = profit.netCompanyProfit >= 0
        ? AppColors.success
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 760;
          final netProfit = _NetProfitBlock(color: netColor, profit: profit);
          final details = _ProfitDetails(profit: profit);

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [netProfit, const SizedBox(height: 16), details],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: netProfit),
              const SizedBox(width: 18),
              Expanded(flex: 7, child: details),
            ],
          );
        },
      ),
    );
  }
}

class CompanyExpensesSection extends StatelessWidget {
  final List<CompanyExpenseModel> expenses;
  final bool loading;
  final bool saving;

  const CompanyExpensesSection({
    super.key,
    required this.expenses,
    required this.loading,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LedgerHeader(
            total: total,
            count: expenses.length,
            saving: saving,
            onAdd: () => _openExpenseDialog(context),
          ),
          if (loading)
            const LinearProgressIndicator(color: AppColors.primary)
          else if (expenses.isEmpty)
            _EmptyLedgerState(onAdd: () => _openExpenseDialog(context))
          else
            _LedgerBody(
              expenses: expenses,
              saving: saving,
              onEdit: (expense) =>
                  _openExpenseDialog(context, expense: expense),
            ),
        ],
      ),
    );
  }

  Future<void> _openExpenseDialog(
    BuildContext context, {
    CompanyExpenseModel? expense,
  }) async {
    final result = await showDialog<_CompanyExpenseFormValue>(
      context: context,
      builder: (_) => _CompanyExpenseDialog(expense: expense),
    );
    if (result == null || !context.mounted) return;
    await context.read<FinancialCubit>().saveCompanyExpense(
      id: expense?.id,
      title: result.title,
      description: result.description,
      category: result.category,
      amount: result.amount,
      transactionDate: result.transactionDate,
    );
  }
}

class _NetProfitBlock extends StatelessWidget {
  final Color color;
  final CompanyProfitModel profit;

  const _NetProfitBlock({required this.color, required this.profit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Icon(Icons.account_balance_outlined, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('صافي ربح الشركة', style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(
                formatKwd(profit.netCompanyProfit),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h4.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Text(
                '${profit.completedProjectCount} مشروع مكتمل داخل الحساب',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfitDetails extends StatelessWidget {
  final CompanyProfitModel profit;

  const _ProfitDetails({required this.profit});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ProfitDetailData(
        label: 'ربح المشاريع المكتملة',
        value: formatKwd(profit.projectProfit),
        icon: Icons.assignment_turned_in_outlined,
      ),
      _ProfitDetailData(
        label: 'مصروفات الشركة',
        value: formatKwd(profit.companyExpenses),
        icon: Icons.receipt_long_outlined,
      ),
      _ProfitDetailData(
        label: 'قيمة المشاريع المكتملة',
        value: formatKwd(profit.completedProjectContractValue),
        icon: Icons.fact_check_outlined,
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          _ProfitDetailChip(
            label: item.label,
            value: item.value,
            icon: item.icon,
          ),
      ],
    );
  }
}

class _ProfitDetailChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfitDetailChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerHeader extends StatelessWidget {
  final double total;
  final int count;
  final bool saving;
  final VoidCallback onAdd;

  const _LedgerHeader({
    required this.total,
    required this.count,
    required this.saving,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;
          final title = Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('دفتر مصروفات الشركة', style: AppTextStyles.h5),
                    const SizedBox(height: 2),
                    Text(
                      '$count عملية في الفترة المحددة',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          );
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatKwd(total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h6.copyWith(color: AppColors.error),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: saving ? null : onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('مصروف جديد'),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 14), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: title),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _LedgerBody extends StatelessWidget {
  final List<CompanyExpenseModel> expenses;
  final bool saving;
  final ValueChanged<CompanyExpenseModel> onEdit;

  const _LedgerBody({
    required this.expenses,
    required this.saving,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                for (int index = 0; index < expenses.length; index++) ...[
                  _MobileExpenseCard(
                    expense: expenses[index],
                    saving: saving,
                    onEdit: onEdit,
                  ),
                  if (index != expenses.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          );
        }
        return _DesktopExpenseLedger(
          expenses: expenses,
          saving: saving,
          onEdit: onEdit,
        );
      },
    );
  }
}

class _DesktopExpenseLedger extends StatelessWidget {
  final List<CompanyExpenseModel> expenses;
  final bool saving;
  final ValueChanged<CompanyExpenseModel> onEdit;

  const _DesktopExpenseLedger({
    required this.expenses,
    required this.saving,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _LedgerTableHeader(),
        for (int index = 0; index < expenses.length; index++)
          _DesktopExpenseRow(
            expense: expenses[index],
            index: index,
            saving: saving,
            onEdit: onEdit,
          ),
      ],
    );
  }
}

class _LedgerTableHeader extends StatelessWidget {
  const _LedgerTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.tableHeader,
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 112,
            child: Text('التاريخ', style: AppTextStyles.tableHeader),
          ),
          Expanded(
            flex: 4,
            child: Text('المصروف', style: AppTextStyles.tableHeader),
          ),
          Expanded(
            flex: 2,
            child: Text('التصنيف', style: AppTextStyles.tableHeader),
          ),
          SizedBox(
            width: 140,
            child: Text('المبلغ', style: AppTextStyles.tableHeader),
          ),
          SizedBox(
            width: 96,
            child: Text('إجراءات', style: AppTextStyles.tableHeader),
          ),
        ],
      ),
    );
  }
}

class _DesktopExpenseRow extends StatelessWidget {
  final CompanyExpenseModel expense;
  final int index;
  final bool saving;
  final ValueChanged<CompanyExpenseModel> onEdit;

  const _DesktopExpenseRow({
    required this.expense,
    required this.index,
    required this.saving,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final rowColor = index.isEven
        ? AppColors.tableRowEven
        : AppColors.tableRowOdd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: rowColor,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              _dateFormat.format(expense.transactionDate),
              style: AppTextStyles.tableCell,
            ),
          ),
          Expanded(flex: 4, child: _ExpenseTitleBlock(expense: expense)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _CategoryBadge(category: expense.category),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              formatKwd(expense.amount),
              textAlign: TextAlign.end,
              style: AppTextStyles.tableCellBold.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          SizedBox(
            width: 96,
            child: _ExpenseActions(
              expense: expense,
              saving: saving,
              onEdit: onEdit,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileExpenseCard extends StatelessWidget {
  final CompanyExpenseModel expense;
  final bool saving;
  final ValueChanged<CompanyExpenseModel> onEdit;

  const _MobileExpenseCard({
    required this.expense,
    required this.saving,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ExpenseTitleBlock(expense: expense)),
              const SizedBox(width: 12),
              Text(
                formatKwd(expense.amount),
                style: AppTextStyles.h6.copyWith(color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.event_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                _dateFormat.format(expense.transactionDate),
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: 10),
              _CategoryBadge(category: expense.category),
              const Spacer(),
              _ExpenseActions(expense: expense, saving: saving, onEdit: onEdit),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseTitleBlock extends StatelessWidget {
  final CompanyExpenseModel expense;

  const _ExpenseTitleBlock({required this.expense});

  @override
  Widget build(BuildContext context) {
    final description = expense.description?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.tableCellBold,
        ),
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String? category;

  const _CategoryBadge({this.category});

  @override
  Widget build(BuildContext context) {
    final text = category?.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.selectedSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.selectedSurfaceStrong),
      ),
      child: Text(
        text == null || text.isEmpty ? 'بدون تصنيف' : text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryLight),
      ),
    );
  }
}

class _ExpenseActions extends StatelessWidget {
  final CompanyExpenseModel expense;
  final bool saving;
  final ValueChanged<CompanyExpenseModel> onEdit;

  const _ExpenseActions({
    required this.expense,
    required this.saving,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'تعديل',
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: saving ? null : () => onEdit(expense),
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primaryLight,
          ),
        ),
        Tooltip(
          message: 'حذف',
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: saving ? null : () => _confirmDelete(context, expense),
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CompanyExpenseModel expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteCompanyExpenseDialog(expense: expense),
    );
    if (confirmed == true && context.mounted) {
      await context.read<FinancialCubit>().deleteCompanyExpense(expense.id);
    }
  }
}

class _EmptyLedgerState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyLedgerState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          const Text('لا توجد مصروفات شركة', style: AppTextStyles.h6),
          const SizedBox(height: 6),
          const Text(
            'أضف أول مصروف ليظهر في حساب صافي ربح الشركة لهذه الفترة.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('إضافة مصروف'),
          ),
        ],
      ),
    );
  }
}

class _CompanyExpenseDialog extends StatefulWidget {
  final CompanyExpenseModel? expense;

  const _CompanyExpenseDialog({this.expense});

  @override
  State<_CompanyExpenseDialog> createState() => _CompanyExpenseDialogState();
}

class _CompanyExpenseDialogState extends State<_CompanyExpenseDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController amountController;
  late final TextEditingController descriptionController;
  late DateTime transactionDate;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    titleController = TextEditingController(text: expense?.title ?? '');
    selectedCategory = _companyExpenseCategories.contains(expense?.category)
        ? expense!.category!
        : _otherCategory;
    amountController = TextEditingController(
      text: expense == null ? '' : expense.amount.toStringAsFixed(3),
    );
    descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    transactionDate = expense?.transactionDate ?? DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditing ? 'تعديل مصروف شركة' : 'إضافة مصروف شركة',
              style: AppTextStyles.h5,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 680,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 520;
                    final amountField = TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTextStyles.inputText,
                      decoration: _inputDecoration(
                        label: 'المبلغ',
                        icon: Icons.payments_outlined,
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');
                        if (amount == null || amount < 0) {
                          return 'أدخل مبلغ صحيح';
                        }
                        return null;
                      },
                    );
                    final dateButton = _DateFieldButton(
                      date: transactionDate,
                      onPressed: _pickDate,
                    );
                    if (isNarrow) {
                      return Column(
                        children: [
                          amountField,
                          const SizedBox(height: 12),
                          dateButton,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: amountField),
                        const SizedBox(width: 12),
                        Expanded(child: dateButton),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: titleController,
                  style: AppTextStyles.inputText,
                  decoration: _inputDecoration(
                    label: 'البند',
                    icon: Icons.title_outlined,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: [
                    for (final category in _companyExpenseCategories)
                      DropdownMenuItem(value: category, child: Text(category)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                  dropdownColor: AppColors.surfaceColor,
                  style: AppTextStyles.inputText,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                  decoration: _inputDecoration(
                    label: 'التصنيف',
                    icon: Icons.sell_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  style: AppTextStyles.inputText,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _inputDecoration(
                    label: 'الوصف',
                    icon: Icons.notes_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('حفظ'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => transactionDate = picked);
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _CompanyExpenseFormValue(
        title: titleController.text.trim(),
        category: selectedCategory,
        description: _blankToNull(descriptionController.text),
        amount: double.parse(amountController.text),
        transactionDate: transactionDate,
      ),
    );
  }
}

class _DateFieldButton extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPressed;

  const _DateFieldButton({required this.date, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
        side: const BorderSide(color: AppColors.inputBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range_outlined, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('التاريخ', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(_dateFormat.format(date), style: AppTextStyles.inputText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteCompanyExpenseDialog extends StatelessWidget {
  final CompanyExpenseModel expense;

  const _DeleteCompanyExpenseDialog({required this.expense});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      title: const Text('حذف مصروف الشركة', style: AppTextStyles.h5),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'سيتم حذف هذا السجل من دفتر مصروفات الشركة.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: AppTextStyles.tableCellBold),
                const SizedBox(height: 6),
                Text(
                  '${_dateFormat.format(expense.transactionDate)}  •  ${formatKwd(expense.amount)}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('حذف'),
        ),
      ],
    );
  }
}

class _ProfitDetailData {
  final String label;
  final String value;
  final IconData icon;

  const _ProfitDetailData({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _CompanyExpenseFormValue {
  final String title;
  final String? category;
  final String? description;
  final double amount;
  final DateTime transactionDate;

  const _CompanyExpenseFormValue({
    required this.title,
    this.category,
    this.description,
    required this.amount,
    required this.transactionDate,
  });
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: AppColors.textMuted),
    labelStyle: AppTextStyles.inputLabel,
    filled: true,
    fillColor: AppColors.inputBackground,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.inputFocusBorder),
    ),
  );
}

final _dateFormat = DateFormat('yyyy/MM/dd');
const _otherCategory = 'أخرى';
const _companyExpenseCategories = [
  'إيجار',
  'رواتب',
  'مواصلات',
  'مشتريات مكتبية',
  'صيانة',
  'تسويق',
  'اتصالات وإنترنت',
  'رسوم حكومية',
  _otherCategory,
];

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
