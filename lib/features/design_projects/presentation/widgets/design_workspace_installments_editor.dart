import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../projects/domain/entities/project_entity.dart';

class DesignWorkspaceInstallmentsEditorDialog extends StatefulWidget {
  final List<ProjectInstallment> initialInstallments;
  final String title;
  final String description;
  final String confirmLabel;

  const DesignWorkspaceInstallmentsEditorDialog({
    super.key,
    required this.initialInstallments,
    this.title = 'تعديل الدفعات',
    this.description = 'يمكنك إضافة أو تعديل أو حذف أي دفعة.',
    this.confirmLabel = 'حفظ التعديلات',
  });

  @override
  State<DesignWorkspaceInstallmentsEditorDialog> createState() =>
      _DesignWorkspaceInstallmentsEditorDialogState();
}

class _InstallmentDraft {
  final String id;
  final TextEditingController amountController;
  DateTime dueDate;
  bool isPaid;

  _InstallmentDraft({
    required this.id,
    required this.amountController,
    required this.dueDate,
    required this.isPaid,
  });

  factory _InstallmentDraft.fromInstallment(ProjectInstallment installment) {
    return _InstallmentDraft(
      id: installment.id,
      amountController: TextEditingController(
        text: installment.amount.toStringAsFixed(2),
      ),
      dueDate: installment.dueDate,
      isPaid: installment.isPaid,
    );
  }

  factory _InstallmentDraft.empty(int index) {
    return _InstallmentDraft(
      id: 'installment-${DateTime.now().microsecondsSinceEpoch}-$index',
      amountController: TextEditingController(),
      dueDate: DateTime.now().add(Duration(days: index * 30)),
      isPaid: false,
    );
  }

  void dispose() {
    amountController.dispose();
  }
}

class _DesignWorkspaceInstallmentsEditorDialogState
    extends State<DesignWorkspaceInstallmentsEditorDialog> {
  final List<_InstallmentDraft> _drafts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _drafts.addAll(
      widget.initialInstallments.map(_InstallmentDraft.fromInstallment),
    );
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  void _addDraft() {
    setState(() {
      _drafts.add(_InstallmentDraft.empty(_drafts.length));
      _errorMessage = null;
    });
  }

  void _removeDraft(int index) {
    setState(() {
      _drafts.removeAt(index).dispose();
      _errorMessage = null;
    });
  }

  Future<void> _pickDate(int index) async {
    final current = _drafts[index].dueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.scaffoldBackground,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _drafts[index].dueDate = picked;
        _errorMessage = null;
      });
    }
  }

  List<ProjectInstallment>? _buildInstallments() {
    final result = <ProjectInstallment>[];
    for (final draft in _drafts) {
      final amount = double.tryParse(draft.amountController.text.trim());
      if (amount == null || amount <= 0) {
        setState(() {
          _errorMessage = 'أدخل قيمة صحيحة لكل دفعة قبل الحفظ';
        });
        return null;
      }
      result.add(
        ProjectInstallment(
          id: draft.id,
          amount: amount,
          dueDate: draft.dueDate,
          isPaid: draft.isPaid,
        ),
      );
    }
    return result;
  }

  void _save() {
    final installments = _buildInstallments();
    if (installments == null) return;
    Navigator.of(context).pop(installments);
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.45),
      disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Dialog(
      backgroundColor: AppColors.cardBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SizedBox(
        width: 760,
        height: 640,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _drafts.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد دفعات حالياً. اضغط إضافة دفعة لإنشاء واحدة.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _drafts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final draft = _drafts[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor.withValues(
                                alpha: 0.58,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'الدفعة ${index + 1}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _drafts.length > 1
                                          ? () => _removeDraft(index)
                                          : null,
                                      icon: const Icon(Icons.delete_outline),
                                      color: AppColors.error,
                                      tooltip: 'حذف الدفعة',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: draft.amountController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: const InputDecoration(
                                          labelText: 'قيمة الدفعة',
                                          suffixText: 'د.ك',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: InkWell(
                                        onTap: () => _pickDate(index),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.inputBackground,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          child: Text(
                                            'تاريخ الاستحقاق: ${draft.dueDate.toLocal().toString().split(' ').first}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: draft.isPaid,
                                      onChanged: (value) {
                                        setState(() {
                                          draft.isPaid = value ?? false;
                                          _errorMessage = null;
                                        });
                                      },
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'تم التحصيل',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _addDraft,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('إضافة دفعة'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _save,
                    style: buttonStyle,
                    child: Text(widget.confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
