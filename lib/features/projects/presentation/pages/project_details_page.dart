import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../financial/data/models/transaction_model.dart';
import '../../../financial/domain/entities/transaction_entity.dart' as tx;
import '../../domain/entities/project_attachment_entity.dart';
import '../../domain/enums/project_status.dart';
import '../cubit/project_financial_cubit.dart';
import '../cubit/project_financial_state.dart';
import '../widgets/delete_transaction_dialog.dart';
import '../widgets/financial_summary_cards_row.dart';
import '../widgets/project_attachments_section.dart';
import '../widgets/project_breadcrumb.dart';
import '../widgets/project_header.dart';
import '../widgets/transactions_table.dart';

/// Project details page showing financial dashboard
/// Refactored to use Cubit for state management and extracted widget components
class ProjectDetailsPage extends StatelessWidget {
  final String projectId;

  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<ProjectFinancialCubit>()..loadProjectFinancialData(projectId),
      child: _ProjectDetailsContent(projectId: projectId),
    );
  }
}

/// Internal content widget that has access to the Cubit
class _ProjectDetailsContent extends StatelessWidget {
  final String projectId;

  const _ProjectDetailsContent({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectFinancialCubit, ProjectFinancialState>(
      builder: (context, state) {
        return ResponsiveLayout(
          mobile: _ProjectDetailsLayout(padding: 16),
          tablet: _ProjectDetailsLayout(padding: 24),
          desktop: _ProjectDetailsLayout(padding: 32),
        );
      },
    );
  }
}

/// Layout wrapper for different screen sizes
class _ProjectDetailsLayout extends StatelessWidget {
  final double padding;

  const _ProjectDetailsLayout({required this.padding});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: BlocBuilder<ProjectFinancialCubit, ProjectFinancialState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb
              ProjectBreadcrumb(
                projectName: state is ProjectFinancialLoaded
                    ? state.project.name
                    : null,
              ),
              const SizedBox(height: 16),

              // Content based on state
              if (state is ProjectFinancialLoading)
                const Center(child: CircularProgressIndicator())
              else if (state is ProjectFinancialError)
                _ErrorView(message: state.message)
              else if (state is ProjectFinancialNotFound)
                const _NotFoundView()
              else if (state is ProjectFinancialLoaded)
                _LoadedContent(state: state),
            ],
          );
        },
      ),
    );
  }
}

/// Content displayed when data is successfully loaded
class _LoadedContent extends StatelessWidget {
  final ProjectFinancialLoaded state;

  const _LoadedContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with project name and status
        ProjectHeader(project: state.project),
        const SizedBox(height: 24),

        // Financial summary cards
        FinancialSummaryCardsRow(financialSummary: state.financialSummary),
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
        ),
        const SizedBox(height: 24),

        // Transactions table
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
              const SnackBar(content: Text('تحميل المزيد - قريباً')),
            );
          },
        ),
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
        const SnackBar(content: Text('تعذر قراءة الملفات المحددة')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم رفع المرفقات بنجاح')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف المرفق')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حذف المعاملة')));
      },
    );
  }
}

/// Error view
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

/// Not found view
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
