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
    final items = [
      _ProfitMetric(
        label: 'ربح المشاريع المكتملة',
        value: formatKwd(profit.projectProfit),
        icon: Icons.assignment_turned_in_outlined,
        color: AppColors.success,
      ),
      _ProfitMetric(
        label: 'مصروفات الشركة',
        value: formatKwd(profit.companyExpenses),
        icon: Icons.receipt_outlined,
        color: AppColors.error,
      ),
      _ProfitMetric(
        label: 'صافي ربح الشركة',
        value: formatKwd(profit.netCompanyProfit),
        icon: Icons.account_balance_outlined,
        color: profit.netCompanyProfit >= 0
            ? AppColors.success
            : AppColors.error,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('ربح الشركة', style: AppTextStyles.h5),
              ),
              Text(
                '${profit.completedProjectCount} مشروع مكتمل',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;
              if (isNarrow) {
                return Column(
                  children: [
                    for (int index = 0; index < items.length; index++) ...[
                      items[index],
                      if (index != items.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int index = 0; index < items.length; index++) ...[
                    Expanded(child: items[index]),
                    if (index != items.length - 1) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('دفتر مصروفات الشركة', style: AppTextStyles.h5),
              ),
              Text(formatKwd(total), style: AppTextStyles.label),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: saving ? null : () => _openExpenseDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة مصروف'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (loading)
            const LinearProgressIndicator(color: AppColors.primary)
          else if (expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text('لا توجد مصروفات شركة في الفترة المحددة'),
              ),
            )
          else
            _CompanyExpensesTable(
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

class _CompanyExpensesTable extends StatelessWidget {
  final List<CompanyExpenseModel> expenses;
  final bool saving;
  final ValueChanged<CompanyExpenseModel> onEdit;

  const _CompanyExpensesTable({
    required this.expenses,
    required this.saving,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: AppTextStyles.label,
        dataTextStyle: AppTextStyles.bodyMedium,
        columns: const [
          DataColumn(label: Text('التاريخ')),
          DataColumn(label: Text('البند')),
          DataColumn(label: Text('التصنيف')),
          DataColumn(label: Text('المبلغ')),
          DataColumn(label: Text('الوصف')),
          DataColumn(label: Text('إجراءات')),
        ],
        rows: [
          for (final expense in expenses)
            DataRow(
              cells: [
                DataCell(Text(_dateFormat.format(expense.transactionDate))),
                DataCell(Text(expense.title)),
                DataCell(
                  Text(
                    expense.category?.isNotEmpty == true
                        ? expense.category!
                        : '-',
                  ),
                ),
                DataCell(Text(formatKwd(expense.amount))),
                DataCell(
                  SizedBox(
                    width: 220,
                    child: Text(
                      expense.description?.isNotEmpty == true
                          ? expense.description!
                          : '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'تعديل',
                        onPressed: saving ? null : () => onEdit(expense),
                        icon: const Icon(Icons.edit_outlined),
                        color: AppColors.primary,
                      ),
                      IconButton(
                        tooltip: 'حذف',
                        onPressed: saving
                            ? null
                            : () => _confirmDelete(context, expense),
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CompanyExpenseModel expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف مصروف الشركة'),
        content: Text('هل تريد حذف "${expense.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<FinancialCubit>().deleteCompanyExpense(expense.id);
    }
  }
}

class _ProfitMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfitMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.statLabel),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h5.copyWith(color: color),
                ),
              ],
            ),
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
  late final TextEditingController categoryController;
  late final TextEditingController amountController;
  late final TextEditingController descriptionController;
  late DateTime transactionDate;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    titleController = TextEditingController(text: expense?.title ?? '');
    categoryController = TextEditingController(text: expense?.category ?? '');
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
    categoryController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.expense == null ? 'إضافة مصروف شركة' : 'تعديل مصروف شركة',
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'البند'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  validator: (value) {
                    final amount = double.tryParse(value ?? '');
                    if (amount == null || amount < 0) return 'أدخل مبلغ صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(_dateFormat.format(transactionDate)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'الوصف'),
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
        FilledButton(onPressed: _submit, child: const Text('حفظ')),
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
        category: _blankToNull(categoryController.text),
        description: _blankToNull(descriptionController.text),
        amount: double.parse(amountController.text),
        transactionDate: transactionDate,
      ),
    );
  }
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

final _dateFormat = DateFormat('yyyy/MM/dd');

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
