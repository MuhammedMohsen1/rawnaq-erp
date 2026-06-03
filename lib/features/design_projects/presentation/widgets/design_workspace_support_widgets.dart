import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../projects/data/datasources/projects_api_datasource.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/domain/enums/project_status.dart';
import '../cubit/design_workspace_cubit.dart';
import 'design_workspace_installments_editor.dart';

class DesignWorkspaceProjectHeader extends StatelessWidget {
  final ProjectEntity project;
  final bool showFinancials;
  final bool canComplete;

  const DesignWorkspaceProjectHeader({
    super.key,
    required this.project,
    required this.showFinancials,
    required this.canComplete,
  });

  @override
  Widget build(BuildContext context) {
    final clientName = project.clientName ?? 'عميل غير محدد';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _workspaceShellDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.palette_outlined,
              color: AppColors.secondaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(clientName, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (canComplete && project.status != ProjectStatus.completed) ...[
            FilledButton.tonalIcon(
              onPressed: () => _markComplete(context),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('إكمال المشروع'),
            ),
            const SizedBox(width: 8),
          ],
          if (showFinancials)
            FilledButton.tonalIcon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<DesignWorkspaceCubit>(),
                  child: DesignWorkspaceFinanceDialog(project: project),
                ),
              ),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('المالية'),
            ),
        ],
      ),
    );
  }

  Future<void> _markComplete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إكمال مشروع التصميم'),
        content: const Text('هل تريد تعليم مشروع التصميم كمكتمل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد الإكمال'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ProjectsApiDataSource().updateProjectStatus(
        project.id,
        ProjectStatus.completed.toApiString(),
        'Marked complete from design workspace',
      );
      if (!context.mounted) return;
      final refresh = DateTime.now().millisecondsSinceEpoch;
      context.go('${AppRoutes.projects}?refresh=$refresh');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعليم مشروع التصميم كمكتمل')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إكمال المشروع: $error')));
    }
  }
}

class DesignWorkspaceFinanceDialog extends StatelessWidget {
  final ProjectEntity project;

  const DesignWorkspaceFinanceDialog({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 960),
        padding: const EdgeInsets.all(24),
        decoration: _workspaceShellDecoration(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'البيانات المالية لمشروع التصميم',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DesignFinanceStrip(project: project),
              const SizedBox(height: 20),
              const DesignInstallmentsPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class DesignFinanceStrip extends StatelessWidget {
  final ProjectEntity project;

  const DesignFinanceStrip({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DesignWorkspaceCubit, DesignWorkspaceState>(
      builder: (context, state) {
        final workspace = state is DesignWorkspaceLoaded
            ? state.workspace
            : null;
        final total = workspace?.projectValue ?? project.projectTotalPrice;
        final received = workspace?.totalReceived ?? project.totalReceived;
        final installments = workspace?.installments ?? project.installments;
        final remaining = total - received;
        final paidInstallments = installments
            .where((installment) => installment.isPaid)
            .length;
        final installmentStatus = installments.isEmpty
            ? 'متابعة من المالية'
            : '$paidInstallments / ${installments.length}';
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FinanceCard(
              label: 'قيمة المشروع',
              value: '${total.toStringAsFixed(0)} د.ك',
            ),
            _FinanceCard(
              label: 'المحصل',
              value: '${received.toStringAsFixed(0)} د.ك',
            ),
            _FinanceCard(
              label: 'المتبقي',
              value: '${remaining.toStringAsFixed(0)} د.ك',
            ),
            _FinanceCard(label: 'حالة الأقساط', value: installmentStatus),
          ],
        );
      },
    );
  }
}

class _FinanceCard extends StatelessWidget {
  final String label;
  final String value;

  const _FinanceCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class DesignInstallmentsPanel extends StatelessWidget {
  const DesignInstallmentsPanel({super.key});

  Future<void> _openInstallmentsEditor(
    BuildContext context,
    List<ProjectInstallment> installments,
  ) async {
    final updated = await showDialog<List<ProjectInstallment>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DesignWorkspaceInstallmentsEditorDialog(
        initialInstallments: installments,
        onUploadCapture: (installment) =>
            _uploadInstallmentCapture(context, installment),
      ),
    );
    if (updated == null || !context.mounted) return;
    await context.read<DesignWorkspaceCubit>().replaceInstallments(updated);
  }

  Future<void> _uploadInstallmentCapture(
    BuildContext context,
    ProjectInstallment installment,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;

    final file = result.files.single;
    await context.read<DesignWorkspaceCubit>().uploadInstallmentCapture(
      installment.id,
      fileName: file.name,
      filePath: file.path,
      bytes: file.path == null ? file.bytes : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DesignWorkspaceCubit, DesignWorkspaceState>(
      builder: (context, state) {
        if (state is! DesignWorkspaceLoaded) {
          return const SizedBox.shrink();
        }
        final installments = state.workspace.installments;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'جدول الأقساط',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: state.isSubmitting
                      ? null
                      : () => _openInstallmentsEditor(context, installments),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('تعديل الأقساط'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (installments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'لا توجد دفعات حالياً. يمكنك إضافة دفعة جديدة من زر التعديل.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () =>
                                _openInstallmentsEditor(context, installments),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.secondary.withValues(
                          alpha: 0.45,
                        ),
                        disabledForegroundColor: AppColors.white.withValues(
                          alpha: 0.7,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إضافة دفعة'),
                    ),
                  ],
                ),
              )
            else
              ...installments.map(
                (installment) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: installment.isPaid,
                          onChanged: state.isSubmitting
                              ? null
                              : (value) {
                                  context
                                      .read<DesignWorkspaceCubit>()
                                      .toggleInstallment(
                                        installment.id,
                                        value ?? false,
                                      );
                                },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${installment.amount.toStringAsFixed(2)} د.ك',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'تاريخ الاستحقاق: ${installment.dueDate.toLocal().toString().split(' ').first}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (installment.captures.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: installment.captures
                                      .map(
                                        (capture) => Chip(
                                          avatar: const Icon(
                                            Icons.receipt_long_outlined,
                                            size: 15,
                                          ),
                                          label: Text(
                                            capture.fileName.isEmpty
                                                ? 'إيصال'
                                                : capture.fileName,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => _openInstallmentsEditor(
                                  context,
                                  installments,
                                ),
                          tooltip: 'تعديل الدفعات',
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
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

class _InstallmentsEditorDialog extends StatefulWidget {
  final List<ProjectInstallment> initialInstallments;

  const _InstallmentsEditorDialog({required this.initialInstallments});

  @override
  State<_InstallmentsEditorDialog> createState() =>
      _InstallmentsEditorDialogState();
}

class _InstallmentsEditorDialogState extends State<_InstallmentsEditorDialog> {
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
                          'تعديل الدفعات',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'يمكنك إضافة أو تعديل أو حذف أي دفعة.',
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
                    child: const Text('حفظ التعديلات'),
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

BoxDecoration _workspaceShellDecoration() => BoxDecoration(
  color: AppColors.cardBackground,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: AppColors.border),
  boxShadow: const [
    BoxShadow(color: Color(0x18000000), blurRadius: 18, offset: Offset(0, 8)),
  ],
);

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.cardBackground,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: AppColors.border),
);

String relativeTime(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'الآن';
  if (difference.inHours < 1) return 'منذ ${difference.inMinutes} دقيقة';
  if (difference.inDays < 1) return 'منذ ${difference.inHours} ساعة';
  return 'منذ ${difference.inDays} يوم';
}
