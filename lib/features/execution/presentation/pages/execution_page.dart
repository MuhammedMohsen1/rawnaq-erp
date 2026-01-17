import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/execution_models.dart';
import '../cubit/execution_cubit.dart';
import '../cubit/execution_state.dart';
import '../widgets/execution_header.dart';
import '../widgets/cash_flow_summary_cards.dart';
import '../widgets/transactions_table.dart';
import '../widgets/pending_approvals_card.dart';
import '../widgets/installments_section.dart';

/// Execution page for projects in EXECUTION status
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
              duration: const Duration(seconds: 4),
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
          return _LoadedContent(projectId: projectId, state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final String projectId;
  final ExecutionLoaded state;

  const _LoadedContent({required this.projectId, required this.state});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _ExecutionLayout(projectId: projectId, padding: 16),
      tablet: _ExecutionLayout(projectId: projectId, padding: 24),
      desktop: _ExecutionLayout(projectId: projectId, padding: 32),
    );
  }
}

class _ExecutionLayout extends StatelessWidget {
  final String projectId;
  final double padding;

  const _ExecutionLayout({required this.projectId, required this.padding});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExecutionCubit, ExecutionState>(
      builder: (context, state) {
        if (state is! ExecutionLoaded) return const SizedBox.shrink();

        final authState = context.read<AuthBloc>().state;

        bool isAdminOrManager = false;
        bool canRequestInstallments = false;
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          isAdminOrManager = user.isAdmin || user.isManager;
          // Any engineer type can request installments (site, junior, senior, or generic engineer)
          canRequestInstallments = user.canRequestInstallments;
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with project name
                ExecutionHeader(
                  projectName: state.dashboard.projectName,
                  onOpenPastPricing: () => _handleOpenPastPricing(context),
                ),
                const SizedBox(height: 24),

                // Cash flow summary cards
                CashFlowSummaryCards(
                  totalReceived: state.dashboard.totalReceived,
                  totalExpenses: state.dashboard.totalExpenses,
                  netCashFlow: state.dashboard.netCashFlow,
                  totalBudget: state.dashboard.totalBudget,
                  totalPrice: state.dashboard.totalPrice,
                  budgetPercentage: state.dashboard.budgetPercentage,
                  budgetWarningLevel: state.dashboard.budgetWarningLevel,
                ),
                const SizedBox(height: 24),

                // Installments section - visible to all users
                if (state.dashboard.paymentSchedule.isNotEmpty)
                  InstallmentsSection(
                    paymentSchedule: state.dashboard.paymentSchedule,
                    totalPrice: state.dashboard.totalPrice,
                    totalCost: state.dashboard.totalBudget,
                    totalProfit: state.dashboard.totalProfit,
                    profitPercentage: state.dashboard.profitPercentage,
                    isAdminOrManager: isAdminOrManager,
                    onToggleCollected: isAdminOrManager
                        ? (phaseIndex, requestId, isCollected) =>
                              _handleToggleCollected(
                                context,
                                requestId,
                                isCollected,
                              )
                        : null,
                  ),
                if (state.dashboard.paymentSchedule.isNotEmpty)
                  const SizedBox(height: 24),

                // Pending approvals (Admin/Manager only)
                if (isAdminOrManager &&
                    state.dashboard.pendingInstallmentRequests.isNotEmpty)
                  PendingApprovalsCard(
                    pendingRequests: state.dashboard.pendingInstallmentRequests,
                    onApprove: (requestId) =>
                        _handleApproveInstallment(context, requestId),
                    onReject: (requestId, reason) =>
                        _handleRejectInstallment(context, requestId, reason),
                  ),
                if (isAdminOrManager &&
                    state.dashboard.pendingInstallmentRequests.isNotEmpty)
                  const SizedBox(height: 24),

                // Transactions table
                TransactionsTable(
                  projectId: projectId,
                  transactions: state.dashboard.transactions,
                  isAddingExpense: state.isAddingExpense,
                  isAddingIncome: state.isAddingIncome,
                  editingTransactions: state.editingTransactions,
                  isLoadingMore: state.isLoadingMore,
                  hasMoreTransactions: state.dashboard.hasMoreTransactions,
                  isSiteEngineer: canRequestInstallments,
                  isAdminOrManager: isAdminOrManager,
                  paymentSchedule: state.dashboard.paymentSchedule,
                  profitPercentage: state.dashboard.profitPercentage,
                  onAddExpense: () => _handleAddExpense(context),
                  onAddIncome: isAdminOrManager
                      ? () => _handleAddIncome(context)
                      : null,
                  onRequestInstallment: canRequestInstallments
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

  void _handleOpenPastPricing(BuildContext context) {
    // Navigate to pricing page with project ID
    context.go(AppRoutes.pricing(projectId));
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
          projectId,
          requestId,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إلغاء تحصيل الدفعة')),
          );
        }
      } else {
        await context.read<ExecutionCubit>().collectInstallment(
          projectId,
          requestId,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم تحصيل الدفعة')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحديث حالة التحصيل: ${e.toString()}')),
        );
      }
    }
  }

  void _handleAddExpense(BuildContext context) {
    context.read<ExecutionCubit>().startAddingExpense();
  }

  void _handleAddIncome(BuildContext context) {
    context.read<ExecutionCubit>().startAddingIncome();
  }

  Future<void> _handleRequestInstallment(
    BuildContext context,
    ExecutionLoaded state,
  ) async {
    // Show dialog to select payment phase
    final availablePhases = state.dashboard.paymentSchedule
        .where((p) => !p.isRequested && !p.isApproved)
        .toList();

    if (availablePhases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد دفعات متاحة للطلب')),
      );
      return;
    }

    final selectedPhase = await showDialog<PaymentPhaseModel>(
      context: context,
      builder: (context) => _RequestInstallmentDialog(
        availablePhases: availablePhases,
        profitPercentage: state.dashboard.profitPercentage,
      ),
    );

    if (selectedPhase != null && context.mounted) {
      try {
        await context.read<ExecutionCubit>().requestInstallment(
          projectId,
          phaseIndex: selectedPhase.index,
          phaseName: selectedPhase.phaseName,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال طلب الدفعة للموافقة')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إرسال الطلب: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _handleApproveInstallment(
    BuildContext context,
    String requestId,
  ) async {
    try {
      await context.read<ExecutionCubit>().approveInstallment(
        projectId,
        requestId,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم قبول طلب الدفعة')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل قبول الطلب: ${e.toString()}')),
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
        projectId,
        requestId,
        reason: reason,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم رفض طلب الدفعة')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل رفض الطلب: ${e.toString()}')),
        );
      }
    }
  }

  void _handleLoadMore(BuildContext context) {
    context.read<ExecutionCubit>().loadMoreTransactions(projectId);
  }
}

class _RequestInstallmentDialog extends StatelessWidget {
  final List<PaymentPhaseModel> availablePhases;
  final double profitPercentage;

  const _RequestInstallmentDialog({
    required this.availablePhases,
    required this.profitPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طلب دفعة'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اختر الدفعة المراد طلبها:'),
            const SizedBox(height: 8),
            Text(
              'سيتم خصم نسبة الربح (${profitPercentage.toStringAsFixed(1)}%) من المبلغ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...availablePhases.map((phase) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(phase.phaseName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبلغ الكامل: ${phase.originalAmount.toStringAsFixed(3)} د.ك',
                      ),
                      Text(
                        'التكلفة (بدون الربح): ${phase.costAmount.toStringAsFixed(3)} د.ك',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(phase),
                    child: const Text('طلب'),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
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
