import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/layout/top_bar_title_controller.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../contracts/data/datasources/contracts_api_datasource.dart';
import '../../../design_projects/presentation/pages/design_project_workspace.dart';
import '../../../design_projects/presentation/widgets/design_workspace_installments_editor.dart';
import '../../../financial/data/models/transaction_model.dart';
import '../../../financial/domain/entities/transaction_entity.dart' as tx;
import '../../../pricing/presentation/widgets/contract_export_dialog.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/project_attachment_entity.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/enums/project_type.dart';
import '../cubit/project_financial_cubit.dart';
import '../cubit/project_financial_state.dart';
import 'delete_transaction_dialog.dart';
import 'financial_summary_cards_row.dart';
import 'project_attachments_section.dart';
import 'project_header.dart';
import 'transactions_table.dart';

bool _isDesignWorkspaceOpen(ProjectStatus status) {
  return status == ProjectStatus.execution || status == ProjectStatus.completed;
}

class ProjectDetailsContent extends StatefulWidget {
  final String projectId;

  const ProjectDetailsContent({super.key, required this.projectId});

  @override
  State<ProjectDetailsContent> createState() => _ProjectDetailsContentState();
}

class _ProjectDetailsContentState extends State<ProjectDetailsContent> {
  @override
  void dispose() {
    TopBarTitleController.clearProjectDetailsTitle();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectFinancialCubit, ProjectFinancialState>(
      listener: (context, state) {
        if (state is ProjectFinancialLoaded) {
          TopBarTitleController.setProjectDetailsTitle(state.project.name);
        } else {
          TopBarTitleController.clearProjectDetailsTitle();
        }
      },
      child: BlocBuilder<ProjectFinancialCubit, ProjectFinancialState>(
        builder: (context, state) {
          return ResponsiveLayout(
            mobile: _ProjectDetailsLayout(padding: 16),
            tablet: _ProjectDetailsLayout(padding: 24),
            desktop: _ProjectDetailsLayout(padding: 32),
          );
        },
      ),
    );
  }
}

class _ProjectDetailsLayout extends StatelessWidget {
  final double padding;

  const _ProjectDetailsLayout({required this.padding});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectFinancialCubit, ProjectFinancialState>(
      builder: (context, state) {
        if (state is ProjectFinancialLoaded &&
            state.project.type == ProjectType.design &&
            _isDesignWorkspaceOpen(state.project.status)) {
          return SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: DesignProjectWorkspace(project: state.project),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state is ProjectFinancialLoading)
                const Center(child: CircularProgressIndicator())
              else if (state is ProjectFinancialError)
                _ErrorView(message: state.message)
              else if (state is ProjectFinancialNotFound)
                const _NotFoundView()
              else if (state is ProjectFinancialLoaded)
                _LoadedContent(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final ProjectFinancialLoaded state;

  const _LoadedContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.project.type == ProjectType.design &&
        _isDesignWorkspaceOpen(state.project.status)) {
      return DesignProjectWorkspace(project: state.project);
    }
    final isContractStage = _canManageContract(state.project);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectHeader(project: state.project),
        if (isContractStage) ...[
          const SizedBox(height: 16),
          _ContractActions(project: state.project),
        ],
        if (!isContractStage) ...[
          const SizedBox(height: 24),
          FinancialSummaryCardsRow(financialSummary: state.financialSummary),
        ],
        const SizedBox(height: 24),
        ProjectAttachmentsSection(
          attachments: state.attachments,
          canDelete:
              !state.project.archived &&
              _canDeleteAttachments(context, state.project.status),
          canUpload: !state.project.archived,
          isUploading: state.isUploadingAttachments,
          isDeleting: state.isDeletingAttachment,
          onUpload: state.project.archived
              ? () {}
              : () => _pickAndUploadAttachments(context),
          onDelete: state.project.archived
              ? (_) {}
              : (attachment) => _confirmDeleteAttachment(context, attachment),
          onReplacePdf: state.project.archived
              ? _noopReplacePdf
              : (attachment, bytes) =>
                    _replacePdfAttachment(context, attachment, bytes),
        ),
        if (!isContractStage) ...[
          const SizedBox(height: 24),
          TransactionsTable(
            transactions: state.transactions,
            onDelete: (transaction) {
              if (!state.project.archived && transaction.canDelete) {
                _showDeleteConfirmation(context, transaction);
              }
            },
            onUpdate: (transaction) {
              if (state.project.archived) return;
              context.read<ProjectFinancialCubit>().updateTransaction(
                transaction,
              );
            },
            onAddNew: state.project.archived
                ? null
                : () => _addNewExpense(context),
            onLoadMore: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text('تحميل المزيد - قريباً'),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  bool _canDeleteAttachments(BuildContext context, ProjectStatus status) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
    final isUnlockedStatus =
        status == ProjectStatus.draft || status == ProjectStatus.underPricing;

    return isAdmin || isUnlockedStatus;
  }

  Future<void> _pickAndUploadAttachments(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    if (!context.mounted) return;

    final filePaths = <String>[];
    final fileBytes = <MapEntry<String, List<int>>>[];

    for (final file in result.files) {
      if (file.path != null) {
        filePaths.add(file.path!);
      } else if (file.bytes != null) {
        fileBytes.add(MapEntry(file.name, file.bytes!));
      }
    }

    if (filePaths.isEmpty && fileBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('تعذر قراءة الملفات المحددة'),
        ),
      );
      return;
    }

    await context.read<ProjectFinancialCubit>().uploadAttachments(
      filePaths,
      fileBytes: fileBytes,
    );

    if (!context.mounted) return;
    final state = context.read<ProjectFinancialCubit>().state;
    if (state is ProjectFinancialLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('تم رفع المرفقات بنجاح'),
        ),
      );
    }
  }

  Future<void> _confirmDeleteAttachment(
    BuildContext context,
    ProjectAttachmentEntity attachment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المرفق'),
        content: Text('هل تريد حذف "${attachment.originalName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<ProjectFinancialCubit>().deleteAttachment(attachment.id);

    if (!context.mounted) return;
    final state = context.read<ProjectFinancialCubit>().state;
    if (state is ProjectFinancialLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('تم حذف المرفق'),
        ),
      );
    }
  }

  Future<void> _replacePdfAttachment(
    BuildContext context,
    ProjectAttachmentEntity attachment,
    List<int> bytes,
  ) async {
    await context.read<ProjectFinancialCubit>().replaceAttachment(
      attachment.id,
      fileBytes: bytes,
      fileName: attachment.originalName.endsWith('.pdf')
          ? attachment.originalName
          : '${attachment.originalName}.pdf',
    );

    if (!context.mounted) return;
    final state = context.read<ProjectFinancialCubit>().state;
    if (state is ProjectFinancialError) {
      throw Exception(state.message);
    }
  }

  void _addNewExpense(BuildContext context) {
    final cubit = context.read<ProjectFinancialCubit>();
    final newTransaction = TransactionModel(
      id: 'txn-new-${DateTime.now().millisecondsSinceEpoch}',
      type: tx.TransactionType.expense,
      description: '',
      amount: 0.0,
      date: DateTime.now(),
      projectId: state.project.id,
      metadata: const tx.TransactionMetadata(isLocked: false),
    );

    cubit.addTransaction(newTransaction);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    tx.TransactionEntity transaction,
  ) {
    DeleteTransactionDialog.show(
      context,
      transaction: transaction,
      onConfirm: () {
        context.read<ProjectFinancialCubit>().deleteTransaction(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('تم حذف المعاملة'),
          ),
        );
      },
    );
  }
}

bool _canManageContract(ProjectEntity project) {
  return project.type == ProjectType.design &&
      (project.status == ProjectStatus.pendingSignature ||
          project.status == ProjectStatus.draft);
}

class _ContractActions extends StatelessWidget {
  final ProjectEntity project;

  const _ContractActions({required this.project});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => ContractExportDialog(
                projectId: project.id,
                projectName: project.name,
                totalAmount: project.projectTotalPrice,
              ),
            ),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('إصدار العقد PDF'),
          ),
          ElevatedButton.icon(
            onPressed: () => _confirmContractAndStart(context),
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: Text(
              project.type == ProjectType.design ? 'بدء العمل' : 'تأكيد العقد',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmContractAndStart(BuildContext context) async {
    try {
      final installments = await showDialog<List<ProjectInstallment>>(
        context: context,
        builder: (_) => DesignWorkspaceInstallmentsEditorDialog(
          initialInstallments: _initialInstallments(project),
          title: 'تأكيد دفعات العقد',
          description: 'راجع الدفعات وحدد ما تم تحصيله قبل تأكيد العقد.',
          confirmLabel: project.type == ProjectType.design
              ? 'تأكيد الدفعات وبدء العمل'
              : 'تأكيد الدفعات والعقد',
        ),
      );
      if (installments == null || installments.isEmpty || !context.mounted) {
        return;
      }

      await ContractsApiDataSource().confirmContract(
        project.id,
        paymentSchedule: _toContractPaymentSchedule(installments),
      );
      if (!context.mounted) return;
      await context.read<ProjectFinancialCubit>().loadProjectFinancialData(
        project.id,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            project.type == ProjectType.design
                ? 'تم فتح مرحلة العمل على مشروع التصميم'
                : 'تم تأكيد العقد ونقل المشروع إلى التنفيذ',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('فشل تأكيد العقد: $e'),
        ),
      );
    }
  }

  List<ProjectInstallment> _initialInstallments(ProjectEntity project) {
    if (project.installments.isNotEmpty) {
      return project.installments;
    }

    final total = project.projectTotalPrice;
    final now = DateTime.now();
    if (total <= 0) {
      return [ProjectInstallment(id: 'installment-1', amount: 0, dueDate: now)];
    }

    return [
      ProjectInstallment(
        id: 'installment-1',
        amount: total * 0.5,
        dueDate: now,
      ),
      ProjectInstallment(
        id: 'installment-2',
        amount: total * 0.5,
        dueDate: now.add(const Duration(days: 30)),
      ),
    ];
  }

  List<Map<String, dynamic>> _toContractPaymentSchedule(
    List<ProjectInstallment> installments,
  ) {
    final total = installments.fold<double>(
      0,
      (sum, installment) => sum + installment.amount,
    );

    return installments.asMap().entries.map((entry) {
      final installment = entry.value;
      final percentage = total > 0 ? installment.amount / total * 100 : 0;
      return {
        'phase': '',
        'percentage': percentage,
        'amount': installment.amount,
        'dueDate': installment.dueDate.toIso8601String(),
        'isPaid': installment.isPaid,
        'notes': installment.notes,
      };
    }).toList();
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'المشروع غير موجود',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

Future<void> _noopReplacePdf(_, __) async {}
