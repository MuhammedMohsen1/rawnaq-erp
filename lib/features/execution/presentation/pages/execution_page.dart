import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:rawnaq/features/projects/domain/entities/project_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../projects/data/datasources/projects_api_datasource.dart';
import '../../../projects/domain/enums/project_status.dart';
import '../../../projects/presentation/widgets/project_attachments_panel.dart';
import '../../../projects/presentation/widgets/project_contact_actions.dart';
import '../../data/models/execution_models.dart';
import '../cubit/execution_cubit.dart';
import '../cubit/execution_state.dart';
import '../widgets/transactions_table.dart';
import '../widgets/pending_approvals_card.dart';
import '../widgets/installments_section.dart';

/// Execution page for projects in EXECUTION or COMPLETED status
class ExecutionPage extends StatelessWidget {
  final String projectId;

  const ExecutionPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExecutionCubit>()..loadDashboard(projectId),
      child: _ExecutionPageContent(projectId: projectId),
    );
  }
}

class _ExecutionPageContent extends StatelessWidget {
  final String projectId;

  const _ExecutionPageContent({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExecutionCubit, ExecutionState>(
      listener: (context, state) {
        if (state is ExecutionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ExecutionLoading) {
          return const Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ExecutionError) {
          return _ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<ExecutionCubit>().loadDashboard(projectId),
          );
        }

        if (state is ExecutionLoaded) {
          return _LoadedContent(state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final ExecutionLoaded state;

  const _LoadedContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _ExecutionLayout(project: state.project, padding: 16),
      tablet: _ExecutionLayout(project: state.project, padding: 24),
      desktop: _ExecutionLayout(project: state.project, padding: 32),
    );
  }
}

class _ExecutionLayout extends StatelessWidget {
  final ProjectEntity project;
  final double padding;

  const _ExecutionLayout({required this.project, required this.padding});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExecutionCubit, ExecutionState>(
      builder: (context, state) {
        if (state is! ExecutionLoaded) return const SizedBox.shrink();

        final authState = context.read<AuthBloc>().state;

        bool isAdminOrManager = false;
        bool canViewProfitData = false;
        bool canRequestInstallments = false;
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          isAdminOrManager = user.isAdmin || user.isManager;
          canViewProfitData = user.isAdmin;
          canRequestInstallments = user.canRequestInstallments;
        }
        final isCompleted = project.status == ProjectStatus.completed;
        final canEditExecution = !isCompleted;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: icon-only buttons ──────────────────────────────
                _CompactExecutionHeader(
                  project: project,
                  onOpenPastPricing: () => _handleOpenPastPricing(context),
                  onOpenPaymentSchedule:
                      isAdminOrManager &&
                          canEditExecution &&
                          state.dashboard.paymentSchedule.isNotEmpty
                      ? () => _handleOpenPaymentScheduleDialog(
                          context,
                          state,
                          canViewProfitData,
                          true,
                        )
                      : null,
                  onMarkComplete: isAdminOrManager && canEditExecution
                      ? () => _handleMarkComplete(context)
                      : null,
                  onReturnToExecution: isAdminOrManager && isCompleted
                      ? () => _handleReturnToExecution(context)
                      : null,
                ),

                const SizedBox(height: 16),

                // ── Pending approvals (Admin/Manager only) ──────────────────
                if (isAdminOrManager &&
                    canEditExecution &&
                    state.dashboard.pendingInstallmentRequests.isNotEmpty)
                  PendingApprovalsCard(
                    pendingRequests: state.dashboard.pendingInstallmentRequests,
                    onApprove: (requestId) =>
                        _handleApproveInstallment(context, requestId),
                    onReject: (requestId, reason) =>
                        _handleRejectInstallment(context, requestId, reason),
                  ),
                if (isAdminOrManager &&
                    canEditExecution &&
                    state.dashboard.pendingInstallmentRequests.isNotEmpty)
                  const SizedBox(height: 16),

                // ── Transactions table ──────────────────────────────────────
                TransactionsTable(
                  project: project,
                  transactions: state.dashboard.transactions,
                  totalReceived: state.dashboard.totalReceived,
                  totalExpenses: state.dashboard.totalExpenses,
                  netCashFlow: state.dashboard.netCashFlow,
                  totalCost: state.dashboard.totalBudget,
                  startDate: state.dashboard.startDate,
                  endDate: state.dashboard.endDate,
                  isAddingExpense: state.isAddingExpense,
                  isAddingIncome: state.isAddingIncome,
                  editingTransactions: state.editingTransactions,
                  isLoadingMore: state.isLoadingMore,
                  hasMoreTransactions: state.dashboard.hasMoreTransactions,
                  isSiteEngineer: canRequestInstallments,
                  isAdminOrManager: canViewProfitData && canEditExecution,
                  paymentSchedule: state.dashboard.paymentSchedule,
                  pendingInstallmentRequests:
                      state.dashboard.pendingInstallmentRequests,
                  profitPercentage: state.dashboard.profitPercentage,
                  onAddExpense: canEditExecution
                      ? () => _handleAddExpense(context)
                      : null,
                  onAddIncome: isAdminOrManager && canEditExecution
                      ? () => _handleAddIncome(context)
                      : null,
                  onRequestInstallment:
                      canRequestInstallments && canEditExecution
                      ? () => _handleRequestInstallment(context, state)
                      : null,
                  onLoadMore: () => _handleLoadMore(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── handlers (unchanged) ──────────────────────────────────────────────────

  void _handleOpenPastPricing(BuildContext context) {
    final state = context.read<ExecutionCubit>().state;
    final version = state is ExecutionLoaded
        ? state.dashboard.pricingVersionNumber
        : null;
    context.push(
      AppRoutes.pricing(
        project.id,
        readOnly: true,
        hideFinancials: true,
        version: version,
      ),
    );
  }

  Future<void> _handleMarkComplete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إكمال المشروع'),
        content: const Text('هل تريد تعليم هذا المشروع كمكتمل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد الإكمال'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ProjectsApiDataSource().updateProjectStatus(
        project.id,
        ProjectStatus.completed.toApiString(),
        'Marked complete from execution',
      );
      if (!context.mounted) return;
      final refreshToken = DateTime.now().millisecondsSinceEpoch;
      context.go('${AppRoutes.projects}?refresh=$refreshToken');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('تم تعليم المشروع كمكتمل'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('فشل إكمال المشروع: ${e.toString()}'),
        ),
      );
    }
  }

  void _handleOpenPaymentScheduleDialog(
    BuildContext context,
    ExecutionLoaded state,
    bool canViewProfitData,
    bool canRequestInstallments,
  ) {
    final scheduleTotal =
        state.dashboard.totalAmountAfterDeduction > 0
        ? state.dashboard.totalAmountAfterDeduction
        : state.dashboard.totalPrice;
    showDialog(
      context: context,
      builder: (dialogContext) => PaymentScheduleDialog(
        paymentSchedule: state.dashboard.paymentSchedule,
        totalPrice: scheduleTotal,
        totalCost: state.dashboard.totalBudget,
        totalProfit: state.dashboard.totalProfit,
        profitPercentage: state.dashboard.profitPercentage,
        isAdminOrManager: canViewProfitData,
        onToggleCollected: canViewProfitData
            ? (phaseIndex, requestId, isCollected) =>
                  _handleToggleCollected(context, requestId, isCollected)
            : null,
        onRequestPaymentPhase: canRequestInstallments
            ? (phase) => _handleRequestInstallmentPhase(
                context,
                phase,
                state.dashboard.profitPercentage,
                canViewProfitData,
              )
            : null,
      ),
    );
  }

  Future<void> _handleReturnToExecution(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة المشروع للتنفيذ'),
        content: const Text('هل تريد إعادة هذا المشروع إلى قيد التنفيذ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد الإعادة'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ProjectsApiDataSource().updateProjectStatus(
        project.id,
        ProjectStatus.execution.toApiString(),
        'Returned to execution from completed',
      );
      if (!context.mounted) return;
      context.read<ExecutionCubit>().loadDashboard(project.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('تمت إعادة المشروع إلى قيد التنفيذ'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('فشل إعادة المشروع: ${e.toString()}'),
        ),
      );
    }
  }

  void _handleAddExpense(BuildContext context) {
    context.read<ExecutionCubit>().startAddingExpense();
  }

  void _handleAddIncome(BuildContext context) {
    context.read<ExecutionCubit>().startAddingIncome();
  }

  Future<void> _handleToggleCollected(
    BuildContext context,
    String? requestId,
    bool isCurrentlyCollected,
  ) async {
    if (requestId == null) return;
    try {
      if (isCurrentlyCollected) {
        await context.read<ExecutionCubit>().uncollectInstallment(
          project.id,
          requestId,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: const Duration(seconds: 2),
              content: Text('تم إلغاء تحصيل بند جدول الدفعات'),
            ),
          );
        }
      } else {
        await context.read<ExecutionCubit>().collectInstallment(
          project.id,
          requestId,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: const Duration(seconds: 2),
              content: Text('تم تحصيل بند جدول الدفعات'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل تحديث حالة التحصيل: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _handleRequestInstallment(
    BuildContext context,
    ExecutionLoaded state,
  ) async {
    final authState = context.read<AuthBloc>().state;
    final canViewProfitData =
        authState is AuthAuthenticated && authState.user.isAdmin;
    final availablePhases = state.dashboard.paymentSchedule
        .where((p) => !p.isRequested && !p.isApproved)
        .toList();

    if (availablePhases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('لا توجد بنود متاحة في جدول الدفعات'),
        ),
      );
      return;
    }

    final selectedRequest = await showDialog<_RequestInstallmentResult>(
      context: context,
      builder: (context) => _RequestInstallmentDialog(
        availablePhases: availablePhases,
        profitPercentage: state.dashboard.profitPercentage,
        canViewProfitData: canViewProfitData,
      ),
    );

    if (selectedRequest != null && context.mounted) {
      try {
        await context.read<ExecutionCubit>().requestInstallment(
          project.id,
          phaseIndex: selectedRequest.phase.index,
          phaseName: selectedRequest.phase.phaseName,
          attachments: selectedRequest.attachments,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: const Duration(seconds: 2),
              content: Text('تم إرسال طلب بند جدول الدفعات للموافقة'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text('فشل إرسال الطلب: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRequestInstallmentPhase(
    BuildContext context,
    PaymentPhaseModel phase,
    double profitPercentage,
    bool canViewProfitData,
  ) async {
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
    if (!isAdmin && (phase.isRequested || phase.isApproved)) return;

    final selectedRequest = await showDialog<_RequestInstallmentResult>(
      context: context,
      builder: (context) => _RequestInstallmentDialog(
        availablePhases: [phase],
        profitPercentage: profitPercentage,
        initialPhase: phase,
        canViewProfitData: canViewProfitData,
      ),
    );

    if (selectedRequest == null || !context.mounted) return;

    try {
      if (isAdmin) {
        await context.read<ExecutionCubit>().payPaymentScheduleItem(
          project.id,
          phaseIndex: selectedRequest.phase.index,
          phaseName: selectedRequest.phase.phaseName,
          requestId: phase.requestId,
          isApproved: phase.isApproved,
          attachments: selectedRequest.attachments,
        );
      } else {
        await context.read<ExecutionCubit>().requestInstallment(
          project.id,
          phaseIndex: selectedRequest.phase.index,
          phaseName: selectedRequest.phase.phaseName,
          attachments: selectedRequest.attachments,
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
              isAdmin
                  ? 'تم دفع بند جدول الدفعات'
                  : 'تم إرسال طلب بند جدول الدفعات للموافقة',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل إرسال الطلب: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _handleApproveInstallment(
    BuildContext context,
    String requestId,
  ) async {
    try {
      await context.read<ExecutionCubit>().approveInstallment(
        project.id,
        requestId,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('تم قبول طلب بند جدول الدفعات'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل قبول الطلب: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _handleRejectInstallment(
    BuildContext context,
    String requestId,
    String reason,
  ) async {
    try {
      await context.read<ExecutionCubit>().rejectInstallment(
        project.id,
        requestId,
        reason: reason,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('تم رفض طلب بند جدول الدفعات'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل رفض الطلب: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _handleLoadMore(BuildContext context) {
    context.read<ExecutionCubit>().loadMoreTransactions(project.id);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPACT HEADER — icon-only action buttons
// ══════════════════════════════════════════════════════════════════════════════

class _CompactExecutionHeader extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onOpenPastPricing;
  final VoidCallback? onOpenPaymentSchedule;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onReturnToExecution;

  const _CompactExecutionHeader({
    required this.project,
    required this.onOpenPastPricing,
    this.onOpenPaymentSchedule,
    this.onMarkComplete,
    this.onReturnToExecution,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Project name — takes all available space
        Expanded(
          child: Text(
            project.name,
            style: AppTextStyles.h3,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),

        _AttachmentsDialogButton(
          projectId: project.id,
          projectStatus: project.status,
        ),
        const SizedBox(width: 8),

        ProjectContactActionsLoader(project: project),
        const SizedBox(width: 8),

        if (onOpenPaymentSchedule != null) ...[
          Tooltip(
            message: 'جدول الدفعات',
            child: IconButton(
              onPressed: onOpenPaymentSchedule,
              icon: const Icon(Icons.payments_outlined),
              color: AppColors.success,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.success.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Past-pricing icon button
        Tooltip(
          message: 'التسعير السابق',
          child: IconButton(
            onPressed: onOpenPastPricing,
            icon: const Icon(Icons.history_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        // Mark-complete icon button (admin / manager only)
        if (onMarkComplete != null) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: 'تعليم كمكتمل',
            child: IconButton(
              onPressed: onMarkComplete,
              icon: const Icon(Icons.check_circle_outline_rounded),
              color: AppColors.success,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.success.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
        if (onReturnToExecution != null) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: 'إعادة إلى قيد التنفيذ',
            child: IconButton(
              onPressed: onReturnToExecution,
              icon: const Icon(Icons.replay_circle_filled_rounded),
              color: AppColors.primary,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AttachmentsDialogButton extends StatelessWidget {
  final String projectId;
  final ProjectStatus projectStatus;

  const _AttachmentsDialogButton({
    required this.projectId,
    required this.projectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Tooltip(
        message: 'المرفقات',
        child: IconButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => Dialog(
              insetPadding: const EdgeInsets.all(16),
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text('المرفقات', style: AppTextStyles.h5),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.textSecondary,
                            tooltip: 'إغلاق',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: SingleChildScrollView(
                          child: ProjectAttachmentsPanel(
                            projectId: projectId,
                            projectStatus: projectStatus,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          icon: const Icon(Icons.attach_file_rounded),
          color: AppColors.primary,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OTHER UNCHANGED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _RequestInstallmentResult {
  final PaymentPhaseModel phase;
  final List<MultipartFile> attachments;

  const _RequestInstallmentResult({
    required this.phase,
    required this.attachments,
  });
}

class _RequestInstallmentDialog extends StatefulWidget {
  final List<PaymentPhaseModel> availablePhases;
  final double profitPercentage;
  final PaymentPhaseModel? initialPhase;
  final bool canViewProfitData;

  const _RequestInstallmentDialog({
    required this.availablePhases,
    required this.profitPercentage,
    this.initialPhase,
    required this.canViewProfitData,
  });

  @override
  State<_RequestInstallmentDialog> createState() =>
      _RequestInstallmentDialogState();
}

class _RequestInstallmentDialogState extends State<_RequestInstallmentDialog> {
  final List<PlatformFile> _attachments = [];
  PaymentPhaseModel? _selectedPhase;
  bool _isPreparing = false;

  @override
  void initState() {
    super.initState();
    _selectedPhase = widget.initialPhase;
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

  Future<void> _submit() async {
    final selectedPhase = _selectedPhase;
    if (selectedPhase == null) return;

    setState(() => _isPreparing = true);
    final attachments = await _buildMultipartAttachments();
    if (!mounted) return;

    Navigator.of(context).pop(
      _RequestInstallmentResult(phase: selectedPhase, attachments: attachments),
    );
  }

  Widget _attachmentsPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _isPreparing ? null : _pickAttachments,
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
          label: Text(
            _attachments.isEmpty
                ? 'إرفاق التقاط شاشة'
                : '${_attachments.length} التقاط',
          ),
        ),
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _attachments.asMap().entries.map((entry) {
              final file = entry.value;
              return Container(
                constraints: const BoxConstraints(maxWidth: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: _isPreparing
                          ? null
                          : () => setState(
                              () => _attachments.removeAt(entry.key),
                            ),
                      child: const Icon(
                        Icons.close,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طلب بند من جدول الدفعات'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اختر بند جدول الدفعات المطلوب:'),
            const SizedBox(height: 8),
            if (widget.canViewProfitData) ...[
              Text(
                'سيتم خصم نسبة الربح (${widget.profitPercentage.toStringAsFixed(1)}%) من المبلغ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 16),
            ...widget.availablePhases.map((phase) {
              final selected = phase.index == _selectedPhase?.index;
              final displayNotes = (phase.notes?.trim().isNotEmpty ?? false)
                  ? phase.notes!.trim()
                  : 'بدون ملاحظات';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  selected: selected,
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  title: Text(displayNotes),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبلغ الكامل: ${phase.originalAmount.toStringAsFixed(3)} د.ك',
                      ),
                      if (widget.canViewProfitData)
                        Text(
                          'التكلفة (بدون الربح): ${phase.costAmount.toStringAsFixed(3)} د.ك',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  onTap: _isPreparing
                      ? null
                      : () => setState(() => _selectedPhase = phase),
                ),
              );
            }),
            const SizedBox(height: 8),
            _attachmentsPicker(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
        ElevatedButton(
          onPressed: _selectedPhase == null || _isPreparing ? null : _submit,
          child: _isPreparing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('إرسال الطلب'),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
