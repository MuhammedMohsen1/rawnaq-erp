import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rawnaq/features/execution/domain/enums/transaction_type.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../projects/data/datasources/projects_api_datasource.dart';
import '../../../projects/domain/enums/project_status.dart';
import '../../../projects/presentation/widgets/project_attachments_panel.dart';
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
          canRequestInstallments = user.canRequestInstallments;
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: icon-only buttons ──────────────────────────────
                _CompactExecutionHeader(
                  projectName: state.dashboard.projectName,
                  onOpenPastPricing: () => _handleOpenPastPricing(context),
                  onMarkComplete: isAdminOrManager
                      ? () => _handleMarkComplete(context)
                      : null,
                ),
                const SizedBox(height: 16),

                ProjectAttachmentsPanel(
                  projectId: projectId,
                  projectStatus: ProjectStatus.execution,
                ),
                const SizedBox(height: 16),

                // ── Accordion: Circular progress + stat cards ──────────────
                _CashFlowAccordion(
                  totalReceived: state.dashboard.totalReceived,
                  totalExpenses: state.dashboard.totalExpenses,
                  netCashFlow: state.dashboard.netCashFlow,
                  totalBudget: state.dashboard.totalBudget,
                  totalPrice: state.dashboard.totalPrice,
                  budgetPercentage: state.dashboard.budgetPercentage,
                  budgetWarningLevel: state.dashboard.budgetWarningLevel,
                  startDate: state.dashboard.startDate,
                  endDate: state.dashboard.endDate,
                ),
                const SizedBox(height: 16),

                // ── Installments ────────────────────────────────────────────
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
                  const SizedBox(height: 16),

                // ── Pending approvals (Admin/Manager only) ──────────────────
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
                  const SizedBox(height: 16),

                // ── Transactions table ──────────────────────────────────────
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
                  pendingInstallmentRequests:
                      state.dashboard.pendingInstallmentRequests,
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

  // ── handlers (unchanged) ──────────────────────────────────────────────────

  void _handleOpenPastPricing(BuildContext context) {
    context.go(AppRoutes.pricing(projectId));
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
        projectId,
        ProjectStatus.completed.toApiString(),
        'Marked complete from execution',
      );
      if (!context.mounted) return;
      context.go(AppRoutes.completedProjects);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تعليم المشروع كمكتمل')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إكمال المشروع: ${e.toString()}')),
      );
    }
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

// ══════════════════════════════════════════════════════════════════════════════
// COMPACT HEADER — icon-only action buttons
// ══════════════════════════════════════════════════════════════════════════════

class _CompactExecutionHeader extends StatelessWidget {
  final String projectName;
  final VoidCallback onOpenPastPricing;
  final VoidCallback? onMarkComplete;

  const _CompactExecutionHeader({
    required this.projectName,
    required this.onOpenPastPricing,
    this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Project name — takes all available space
        Expanded(
          child: Text(
            projectName,
            style: AppTextStyles.h3,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        // Past-pricing icon button
        Tooltip(
          message: 'التسعير السابق',
          child: IconButton(
            onPressed: onOpenPastPricing,
            icon: const Icon(Icons.history_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.08),
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
                backgroundColor: AppColors.success.withOpacity(0.08),
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

// ══════════════════════════════════════════════════════════════════════════════
// CASH FLOW ACCORDION
//   Header  → two Syncfusion circular progress rings (always visible)
//   Body    → CashFlowSummaryCards (collapsed by default)
// ══════════════════════════════════════════════════════════════════════════════

class _CashFlowAccordion extends StatefulWidget {
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final double totalBudget;
  final double totalPrice;
  final double budgetPercentage;
  final BudgetWarningLevel budgetWarningLevel;
  final DateTime? startDate;
  final DateTime? endDate;

  const _CashFlowAccordion({
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.totalBudget,
    required this.totalPrice,
    required this.budgetPercentage,
    required this.budgetWarningLevel,
    this.startDate,
    this.endDate,
  });

  @override
  State<_CashFlowAccordion> createState() => _CashFlowAccordionState();
}

class _CashFlowAccordionState extends State<_CashFlowAccordion>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _arrowAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(_arrowController);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _arrowController.forward();
    } else {
      _arrowController.reverse();
    }
  }

  // ── progress helpers ──────────────────────────────────────────────────────

  /// Budget used: totalExpenses / totalBudget  (clamped 0–100)
  double get _cashProgress {
    if (widget.totalBudget <= 0) return 0;
    return (widget.totalExpenses / widget.totalBudget * 100).clamp(0.0, 100.0);
  }

  /// Time elapsed: (today - startDate) / (endDate - startDate)  (clamped 0–100)
  double get _dateProgress {
    final start = widget.startDate;
    final end = widget.endDate;
    if (start == null || end == null) return 0;
    final totalDays = end.difference(start).inDays;
    if (totalDays <= 0) return 100;
    final elapsed = DateTime.now().difference(start).inDays;
    return (elapsed / totalDays * 100).clamp(0.0, 100.0);
  }

  /// Returns color based on how close to 100 % the value is.
  Color _progressColor(double value) {
    if (value >= 90) return const Color(0xFFE53935); // red
    if (value >= 70) return const Color(0xFFFB8C00); // orange
    return const Color(0xFF43A047); // green
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Always-visible header with circular gauges ────────────────────
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Cash progress gauge
                  _CircularGauge(
                    value: _cashProgress,
                    color: _progressColor(_cashProgress),
                    label: 'الميزانية',
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(width: 20),

                  // Date progress gauge
                  _CircularGauge(
                    value: _dateProgress,
                    color: _progressColor(_dateProgress),
                    label: 'المدة',
                    icon: Icons.calendar_today_rounded,
                  ),

                  const Spacer(),

                  // Expand/collapse arrow
                  Column(
                    children: [
                      Text(
                        'تفاصيل التدفق النقدي',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RotationTransition(
                        turns: _arrowAnimation,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible body: existing stat cards ─────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CashFlowSummaryCards(
                totalReceived: widget.totalReceived,
                totalExpenses: widget.totalExpenses,
                netCashFlow: widget.netCashFlow,
                totalBudget: widget.totalBudget,
                totalPrice: widget.totalPrice,
                budgetPercentage: widget.budgetPercentage,
                budgetWarningLevel: widget.budgetWarningLevel,
                startDate: widget.startDate,
                endDate: widget.endDate,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SYNCFUSION CIRCULAR GAUGE WIDGET
// Requires: syncfusion_flutter_gauges in pubspec.yaml
// ══════════════════════════════════════════════════════════════════════════════

class _CircularGauge extends StatelessWidget {
  final double value; // 0–100
  final Color color;
  final String label;
  final IconData icon;

  const _CircularGauge({
    required this.value,
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: SfRadialGauge(
            axes: [
              RadialAxis(
                minimum: 0,
                maximum: 100,
                startAngle: 270,
                endAngle: 270,
                showTicks: false,
                showLabels: false,
                axisLineStyle: AxisLineStyle(
                  thickness: 0.12,
                  thicknessUnit: GaugeSizeUnit.factor,
                  color: color.withOpacity(0.15),
                ),
                pointers: [
                  RangePointer(
                    value: value,
                    width: 0.12,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: color,
                    enableAnimation: true,
                    animationType: AnimationType.easeOutBack,
                    animationDuration: 1200,
                    cornerStyle: CornerStyle.bothCurve,
                  ),
                ],
                annotations: [
                  GaugeAnnotation(
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: color),
                        const SizedBox(height: 2),
                        Text(
                          '${value.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    angle: 90,
                    positionFactor: 0.1,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OTHER UNCHANGED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

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
