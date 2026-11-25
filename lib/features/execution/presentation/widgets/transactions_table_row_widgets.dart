import 'package:rawnaq/core/widgets/app_toast.dart';
import 'package:rawnaq/core/utils/arabic_number_input_formatter.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/dialog_keyboard_actions.dart';
import '../../data/models/execution_models.dart';
import '../../domain/enums/transaction_type.dart';
import '../cubit/execution_cubit.dart';
import 'add_expense_compact_form.dart';
import 'add_income_row_content.dart';
import 'transaction_attachments.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

/// Converts Arabic numerals (٠١٢٣٤٥٦٧٨٩) to English numerals (0123456789)
String convertArabicToEnglishNumerals(String input) {
  const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const englishNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  String result = input;
  for (int i = 0; i < arabicNumerals.length; i++) {
    result = result.replaceAll(arabicNumerals[i], englishNumerals[i]);
  }
  result = result.replaceAll('٫', '.');
  return result;
}

/// Parse a number string that may contain Arabic numerals
double? parseNumber(String text) {
  final normalized = convertArabicToEnglishNumerals(text.trim());
  return double.tryParse(normalized);
}

class TransactionRow extends StatelessWidget {
  final String projectId;
  final TransactionModel transaction;
  final bool isEditing;
  final bool isCompact;
  final bool isAdminOrManager;
  final String installmentRequestId;

  const TransactionRow({
    super.key,
    required this.projectId,
    required this.transaction,
    required this.isEditing,
    required this.isCompact,
    required this.isAdminOrManager,
    required this.installmentRequestId,
  });

  @override
  Widget build(BuildContext context) {
    final isInstallment = transaction.source.toLowerCase() == 'installment';
    final canEditInstallment = isAdminOrManager && isInstallment;

    if (isEditing && canEditInstallment) {
      return EditableInstallmentRow(
        projectId: projectId,
        transaction: transaction,
        installmentRequestId: installmentRequestId,
        onCancel: () =>
            context.read<ExecutionCubit>().cancelEditing(transaction.id),
        isCompact: isCompact,
      );
    }

    if (isEditing && transaction.isEditable) {
      return EditableExpenseRow(
        projectId: projectId,
        transaction: transaction,
        onCancel: () =>
            context.read<ExecutionCubit>().cancelEditing(transaction.id),
        isCompact: isCompact,
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    final isIncome = transaction.type == TransactionType.income;
    final canEdit = isInstallment ? canEditInstallment : transaction.isEditable;

    if (isCompact) {
      return _CompactTransactionRow(
        transaction: transaction,
        isIncome: isIncome,
        canEdit: canEdit,
        installmentRequestId: installmentRequestId,
        projectId: projectId,
        dateFormat: dateFormat,
        isInstallment: isInstallment,
      );
    }

    return _WideTransactionRow(
      transaction: transaction,
      isIncome: isIncome,
      canEdit: canEdit,
      installmentRequestId: installmentRequestId,
      projectId: projectId,
      dateFormat: dateFormat,
      isInstallment: isInstallment,
    );
  }
}

class _CompactTransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final bool isIncome;
  final bool canEdit;
  final String installmentRequestId;
  final String projectId;
  final DateFormat dateFormat;
  final bool isInstallment;

  const _CompactTransactionRow({
    required this.transaction,
    required this.isIncome,
    required this.canEdit,
    required this.installmentRequestId,
    required this.projectId,
    required this.dateFormat,
    required this.isInstallment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.of(context).border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isIncome
                  ? AppColors.of(context).success.withValues(alpha: 0.1)
                  : AppColors.of(context).error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome
                  ? AppColors.of(context).success
                  : AppColors.of(context).error,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ArabicNumberTransformer.transform(transaction.description),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    context,
                  ).tableCellBold.copyWith(fontSize: 13),
                ),
                if (transaction.subDescription != null)
                  Text(
                    ArabicNumberTransformer.transform(
                      transaction.subDescription!,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.of(context).caption,
                  ),
                Text(
                  ArabicNumberTransformer.transform(
                    dateFormat.format(transaction.date),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(context).caption,
                ),
                if (transaction.attachments.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  TransactionAttachments(
                    attachments: transaction.attachments,
                    compact: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ArabicNumberTransformer.transform(
                  '${isIncome ? '+' : ''}${transaction.amount.toStringAsFixed(3)}',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.of(context).tableCellBold.copyWith(
                  color: isIncome
                      ? AppColors.of(context).success
                      : AppColors.of(context).error,
                  fontSize: 13,
                ),
                textAlign: TextAlign.end,
              ),
              if (canEdit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => context
                            .read<ExecutionCubit>()
                            .toggleEditing(transaction.id),
                        icon: const Icon(Icons.edit, size: 15),
                        tooltip: 'تعديل',
                        color: AppColors.of(context).textSecondary,
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => isInstallment
                            ? showDeleteInstallmentConfirmation(
                                context,
                                projectId,
                                installmentRequestId,
                              )
                            : showDeleteConfirmation(
                                context,
                                projectId,
                                transaction.id,
                              ),
                        icon: const Icon(Icons.delete_outline, size: 15),
                        tooltip: 'حذف',
                        color: AppColors.of(context).error,
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

class _WideTransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final bool isIncome;
  final bool canEdit;
  final String installmentRequestId;
  final String projectId;
  final DateFormat dateFormat;
  final bool isInstallment;

  const _WideTransactionRow({
    required this.transaction,
    required this.isIncome,
    required this.canEdit,
    required this.installmentRequestId,
    required this.projectId,
    required this.dateFormat,
    required this.isInstallment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.of(context).border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isIncome
                    ? AppColors.of(context).success.withValues(alpha: 0.1)
                    : AppColors.of(context).error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome
                    ? AppColors.of(context).success
                    : AppColors.of(context).error,
                size: 18,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ArabicNumberTransformer.transform(transaction.description),
                  style: AppTextStyles.of(context).tableCellBold,
                ),
                if (transaction.subDescription != null)
                  Text(
                    ArabicNumberTransformer.transform(
                      transaction.subDescription!,
                    ),
                    style: AppTextStyles.of(context).bodySmall,
                  ),
                if (transaction.attachments.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  TransactionAttachments(
                    attachments: transaction.attachments,
                    compact: false,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              ArabicNumberTransformer.transform(
                dateFormat.format(transaction.date),
              ),
              style: AppTextStyles.of(context).tableCell,
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              ArabicNumberTransformer.transform(
                '${isIncome ? '+' : ''}${transaction.amount.toStringAsFixed(3)}',
              ),
              style: AppTextStyles.of(context).tableCellBold.copyWith(
                color: isIncome
                    ? AppColors.of(context).success
                    : AppColors.of(context).error,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(
            width: 100,
            child: canEdit
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => context
                            .read<ExecutionCubit>()
                            .toggleEditing(transaction.id),
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'تعديل',
                        color: AppColors.of(context).textSecondary,
                      ),
                      IconButton(
                        onPressed: () => isInstallment
                            ? showDeleteInstallmentConfirmation(
                                context,
                                projectId,
                                installmentRequestId,
                              )
                            : showDeleteConfirmation(
                                context,
                                projectId,
                                transaction.id,
                              ),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        tooltip: 'حذف',
                        color: AppColors.of(context).error,
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

void showDeleteConfirmation(
  BuildContext context,
  String projectId,
  String transactionId,
) {
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
            context.read<ExecutionCubit>().deleteExpense(
              projectId,
              transactionId,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.of(context).error,
          ),
          child: const Text('حذف'),
        ),
      ],
    ),
  );
}

void showDeleteInstallmentConfirmation(
  BuildContext context,
  String projectId,
  String installmentId,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: const Text('هل أنت متأكد من حذف هذه الدفعة؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            try {
              await context.read<ExecutionCubit>().deleteInstallment(
                projectId,
                installmentId,
              );
            } catch (e) {
              if (context.mounted) {
                final message = 'فشل حذف الدفعة: ${e.toString()}';
                ScaffoldMessenger.of(context).showSnackBar(
                  AppToast.build(
                    tone: ToastTone.error,
                    duration: const Duration(seconds: 2),
                    content: Text(ArabicNumberTransformer.transform(message)),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.of(context).error,
          ),
          child: const Text('حذف'),
        ),
      ],
    ),
  );
}

class AddExpenseRow extends StatefulWidget {
  final String projectId;
  final VoidCallback onCancel;
  final bool isCompact;
  final ExecutionCubit cubit;

  const AddExpenseRow({
    super.key,
    required this.projectId,
    required this.onCancel,
    required this.isCompact,
    required this.cubit,
  });

  @override
  State<AddExpenseRow> createState() => _AddExpenseRowState();
}

class _AddExpenseRowState extends State<AddExpenseRow> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _quantityController = TextEditingController();
  final CostType _costType = CostType.total;
  final DateTime _selectedDate = DateTime.now();
  bool _isReturnedExpense = false;
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
    return DialogKeyboardActions(
      enabled: !_isSubmitting,
      onSubmit: _submitExpense,
      onClose: widget.onCancel,
      child: BlocProvider.value(
        value: widget.cubit,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.of(context).background.withValues(alpha: 0.05),
          child: widget.isCompact ? _buildCompactForm() : _buildWideForm(),
        ),
      ),
    );
  }

  Widget _buildCompactForm() {
    return AddExpenseCompactForm(
      amountController: _amountController,
      unitCostController: _unitCostController,
      quantityController: _quantityController,
      nameController: _nameController,
      isSubmitting: _isSubmitting,
      isReturnedExpense: _isReturnedExpense,
      showTotalAmount: _costType == CostType.total,
      onCancel: widget.onCancel,
      onSubmit: _submitExpense,
      onReturnedExpenseChanged: (value) {
        setState(() => _isReturnedExpense = value);
      },
    );
  }

  Widget _buildWideForm() {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.of(context).error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_upward,
              color: AppColors.of(context).error,
              size: 18,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            inputFormatters: const [ArabicNumberInputFormatter()],
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'اسم البند',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_costType == CostType.total)
          SizedBox(
            width: 120,
            child: TextField(
              inputFormatters: const [ArabicNumberInputFormatter()],
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'المبلغ',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          )
        else ...[
          SizedBox(
            width: 80,
            child: TextField(
              inputFormatters: const [ArabicNumberInputFormatter()],
              controller: _unitCostController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'سعر الوحدة',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
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
              inputFormatters: const [ArabicNumberInputFormatter()],
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'الكمية',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        SizedBox(
          width: 128,
          child: CheckboxListTile(
            value: _isReturnedExpense,
            onChanged: (value) {
              setState(() => _isReturnedExpense = value ?? false);
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'مرتجع',
              style: AppTextStyles.of(
                context,
              ).caption.copyWith(color: AppColors.of(context).success),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: Icon(Icons.close, color: AppColors.of(context).error),
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
                  : Icon(Icons.check, color: AppColors.of(context).success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitExpense() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppToast.build(
          tone: ToastTone.warning,
          duration: Duration(seconds: 2),
          content: Text('يرجى إدخال اسم المصروف'),
        ),
      );
      return;
    }

    double? amount;
    double? unitCost;
    double? quantity;

    if (_costType == CostType.total) {
      amount = parseNumber(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.warning,
            duration: Duration(seconds: 2),
            content: Text('يرجى إدخال مبلغ صحيح'),
          ),
        );
        return;
      }
    } else {
      unitCost = parseNumber(_unitCostController.text);
      quantity = parseNumber(_quantityController.text);
      if (unitCost == null ||
          quantity == null ||
          unitCost <= 0 ||
          quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.warning,
            duration: Duration(seconds: 2),
            content: Text('يرجى إدخال سعر الوحدة والكمية'),
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = CreateExpenseDto(
        name: name,
        type: _isReturnedExpense ? 'RETURNED' : 'DAILY',
        costType: _costType == CostType.total ? 'TOTAL' : 'UNIT_BASED',
        amount: amount,
        unitCost: unitCost,
        quantity: quantity,
        date: _selectedDate,
      );

      await widget.cubit.addExpense(widget.projectId, dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.success,
            duration: Duration(seconds: 2),
            content: Text('تم إضافة المصروف بنجاح'),
          ),
        );
        widget.onCancel();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.error,
            duration: Duration(seconds: 2),
            content: Text(
              ArabicNumberTransformer.transform(
                'فشل إضافة المصروف: ${e.toString()}',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class EditableExpenseRow extends StatefulWidget {
  final String projectId;
  final TransactionModel transaction;
  final VoidCallback onCancel;
  final bool isCompact;

  const EditableExpenseRow({
    super.key,
    required this.projectId,
    required this.transaction,
    required this.onCancel,
    required this.isCompact,
  });

  @override
  State<EditableExpenseRow> createState() => _EditableExpenseRowState();
}

class _EditableExpenseRowState extends State<EditableExpenseRow> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _unitCostController;
  late TextEditingController _quantityController;
  late CostType _costType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.transaction.description,
    );
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
    return DialogKeyboardActions(
      enabled: !_isSubmitting,
      onSubmit: _submitUpdate,
      onClose: widget.onCancel,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.of(context).primary.withValues(alpha: 0.05),
        child: widget.isCompact ? _buildCompactForm() : _buildWideForm(),
      ),
    );
  }

  Widget _buildCompactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.of(context).error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward,
                color: AppColors.of(context).error,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'تعديل المصروف',
              style: AppTextStyles.of(context).tableCellBold,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_costType == CostType.total)
          TextField(
            inputFormatters: const [ArabicNumberInputFormatter()],
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              hintText: 'المبلغ',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: TextField(
                  inputFormatters: const [ArabicNumberInputFormatter()],
                  controller: _unitCostController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'سعر الوحدة',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  inputFormatters: const [ArabicNumberInputFormatter()],
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'الكمية',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        TextField(
          inputFormatters: const [ArabicNumberInputFormatter()],
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'اسم المصروف',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: Icon(Icons.close, color: AppColors.of(context).error),
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
                  : Icon(Icons.check, color: AppColors.of(context).success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideForm() {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.of(context).error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_upward,
              color: AppColors.of(context).error,
              size: 18,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            inputFormatters: const [ArabicNumberInputFormatter()],
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'اسم المصروف',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_costType == CostType.total)
          SizedBox(
            width: 120,
            child: TextField(
              inputFormatters: const [ArabicNumberInputFormatter()],
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'المبلغ',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          )
        else ...[
          SizedBox(
            width: 80,
            child: TextField(
              inputFormatters: const [ArabicNumberInputFormatter()],
              controller: _unitCostController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'سعر الوحدة',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
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
              inputFormatters: const [ArabicNumberInputFormatter()],
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'الكمية',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: Icon(Icons.close, color: AppColors.of(context).error),
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
                  : Icon(Icons.check, color: AppColors.of(context).success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitUpdate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppToast.build(
          tone: ToastTone.warning,
          duration: Duration(seconds: 2),
          content: Text('يرجى إدخال اسم المصروف'),
        ),
      );
      return;
    }

    double? amount;
    double? unitCost;
    double? quantity;

    if (_costType == CostType.total) {
      amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.warning,
            duration: Duration(seconds: 2),
            content: Text('يرجى إدخال مبلغ صحيح'),
          ),
        );
        return;
      }
    } else {
      unitCost = double.tryParse(_unitCostController.text);
      quantity = double.tryParse(_quantityController.text);
      if (unitCost == null ||
          quantity == null ||
          unitCost <= 0 ||
          quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.warning,
            duration: Duration(seconds: 2),
            content: Text('يرجى إدخال سعر الوحدة والكمية'),
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = UpdateExpenseDto(
        name: name,
        costType: _costType == CostType.total ? 'TOTAL' : 'UNIT_BASED',
        amount: amount,
        unitCost: unitCost,
        quantity: quantity,
      );

      final cubit = context.read<ExecutionCubit>();
      await cubit.updateExpense(widget.projectId, widget.transaction.id, dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.success,
            duration: Duration(seconds: 2),
            content: Text('تم تحديث المصروف بنجاح'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.error,
            duration: Duration(seconds: 2),
            content: Text(
              ArabicNumberTransformer.transform(
                'فشل تحديث المصروف: ${e.toString()}',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class EditableInstallmentRow extends StatefulWidget {
  final String projectId;
  final TransactionModel transaction;
  final String installmentRequestId;
  final VoidCallback onCancel;
  final bool isCompact;

  const EditableInstallmentRow({
    super.key,
    required this.projectId,
    required this.transaction,
    required this.installmentRequestId,
    required this.onCancel,
    required this.isCompact,
  });

  @override
  State<EditableInstallmentRow> createState() => _EditableInstallmentRowState();
}

class _EditableInstallmentRowState extends State<EditableInstallmentRow> {
  late TextEditingController _nameController;
  late TextEditingController _originalAmountController;
  late TextEditingController _requestedAmountController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.transaction.description,
    );
    _originalAmountController = TextEditingController();
    _requestedAmountController = TextEditingController(
      text: widget.transaction.amount.abs().toString(),
    );
    if (widget.transaction.originalAmount != null) {
      _originalAmountController.text = widget.transaction.originalAmount!
          .toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originalAmountController.dispose();
    _requestedAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogKeyboardActions(
      enabled: !_isSubmitting,
      onSubmit: _submitUpdate,
      onClose: widget.onCancel,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.of(context).primary.withValues(alpha: 0.05),
        child: widget.isCompact ? _buildCompactForm() : _buildWideForm(),
      ),
    );
  }

  Widget _buildCompactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.of(context).success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_downward,
                color: AppColors.of(context).success,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'تعديل الدفعة',
              style: AppTextStyles.of(context).tableCellBold,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          inputFormatters: const [ArabicNumberInputFormatter()],
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'اسم الدفعة',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          inputFormatters: const [ArabicNumberInputFormatter()],
          controller: _originalAmountController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          decoration: const InputDecoration(
            hintText: 'المبلغ الأصلي',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          inputFormatters: const [ArabicNumberInputFormatter()],
          controller: _requestedAmountController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          decoration: const InputDecoration(
            hintText: 'المبلغ المطلوب',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: Icon(Icons.close, color: AppColors.of(context).error),
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
                  : Icon(Icons.check, color: AppColors.of(context).success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideForm() {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.of(context).success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_downward,
              color: AppColors.of(context).success,
              size: 18,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            inputFormatters: const [ArabicNumberInputFormatter()],
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'اسم الدفعة',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextField(
            inputFormatters: const [ArabicNumberInputFormatter()],
            controller: _originalAmountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              hintText: 'المبلغ الأصلي',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextField(
            inputFormatters: const [ArabicNumberInputFormatter()],
            controller: _requestedAmountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              hintText: 'المبلغ المطلوب',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: Icon(Icons.close, color: AppColors.of(context).error),
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
                  : Icon(Icons.check, color: AppColors.of(context).success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitUpdate() async {
    final name = _nameController.text.trim();
    final originalAmount = parseNumber(_originalAmountController.text);
    final requestedAmount = parseNumber(_requestedAmountController.text);

    final hasOriginal = originalAmount != null && originalAmount > 0;
    final hasRequested = requestedAmount != null && requestedAmount > 0;

    if (name.isEmpty && !hasOriginal && !hasRequested) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppToast.build(
          tone: ToastTone.warning,
          duration: Duration(seconds: 2),
          content: Text('يرجى إدخال الاسم أو المبالغ'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = UpdateInstallmentDto(
        phaseName: name.isEmpty ? null : name,
        originalAmount: hasOriginal ? originalAmount : null,
        requestedAmount: hasRequested ? requestedAmount : null,
      );
      final cubit = context.read<ExecutionCubit>();
      await cubit.updateInstallment(
        widget.projectId,
        widget.installmentRequestId,
        dto,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.success,
            duration: Duration(seconds: 2),
            content: Text('تم تحديث الدفعة بنجاح'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = 'فشل تحديث الدفعة: ${e.toString()}';
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.error,
            duration: Duration(seconds: 2),
            content: Text(ArabicNumberTransformer.transform(message)),
          ),
        );
        context.read<ExecutionCubit>().cancelEditing(widget.transaction.id);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLoadMore;

  const LoadMoreButton({
    super.key,
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
                  style: AppTextStyles.of(context).link,
                ),
              ),
      ),
    );
  }
}

class AddIncomeRow extends StatefulWidget {
  final String projectId;
  final VoidCallback onCancel;
  final bool isCompact;
  final ExecutionCubit cubit;
  const AddIncomeRow({
    super.key,
    required this.projectId,
    required this.onCancel,
    required this.isCompact,
    required this.cubit,
  });

  @override
  State<AddIncomeRow> createState() => _AddIncomeRowState();
}

class _AddIncomeRowState extends State<AddIncomeRow> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<PlatformFile> _attachments = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogKeyboardActions(
      enabled: !_isSubmitting,
      onSubmit: _submitIncome,
      onClose: widget.onCancel,
      child: BlocProvider.value(
        value: widget.cubit,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.of(context).background.withValues(alpha: 0.05),
          child: AddIncomeRowContent(
            isCompact: widget.isCompact,
            isSubmitting: _isSubmitting,
            descriptionController: _descriptionController,
            amountController: _amountController,
            selectedDate: _selectedDate,
            attachments: _attachments,
            onCancel: widget.onCancel,
            onSubmit: _submitIncome,
            onPickAttachments: _pickAttachments,
            onRemoveAttachment: (index) =>
                setState(() => _attachments.removeAt(index)),
            onDateChanged: (date) => setState(() => _selectedDate = date),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _attachments
        ..clear()
        ..addAll(result.files);
    });
  }

  Future<List<MultipartFile>> _buildMultipartAttachments() async {
    final files = <MultipartFile>[];
    for (final file in _attachments) {
      if (file.path != null) {
        files.add(
          await MultipartFile.fromFile(file.path!, filename: file.name),
        );
      } else if (file.bytes != null) {
        files.add(MultipartFile.fromBytes(file.bytes!, filename: file.name));
      }
    }
    return files;
  }

  Future<void> _submitIncome() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppToast.build(
          tone: ToastTone.warning,
          duration: Duration(seconds: 2),
          content: Text('يرجى إدخال وصف الإيراد'),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppToast.build(
          tone: ToastTone.warning,
          duration: Duration(seconds: 2),
          content: Text('يرجى إدخال مبلغ صحيح'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = CreateIncomeDto(
        description: description,
        amount: amount,
        date: _selectedDate,
      );

      final attachments = await _buildMultipartAttachments();
      await widget.cubit.addIncome(
        widget.projectId,
        dto,
        attachments: attachments,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.success,
            duration: Duration(seconds: 2),
            content: Text('تم إضافة الإيراد بنجاح'),
          ),
        );
        widget.onCancel();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: ToastTone.error,
            duration: Duration(seconds: 2),
            content: Text(
              ArabicNumberTransformer.transform(
                'فشل إضافة الإيراد: ${e.toString()}',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
