import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../data/models/execution_models.dart';
import '../cubit/execution_cubit.dart';
import 'transactions_table_row_widgets.dart';
import 'transactions_table_support_widgets.dart';

class TransactionsTable extends StatelessWidget {
  final ProjectEntity project;
  final List<TransactionModel> transactions;
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final double totalCost;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isAddingExpense;
  final bool isAddingIncome;
  final Map<String, bool> editingTransactions;
  final bool isLoadingMore;
  final bool hasMoreTransactions;

  /// Whether the user can request installments (engineers)
  final bool isSiteEngineer;
  final bool isAdminOrManager;
  final List<PaymentPhaseModel> paymentSchedule;
  final List<InstallmentRequestModel> pendingInstallmentRequests;
  final double profitPercentage;
  final VoidCallback? onAddExpense;
  final VoidCallback? onAddIncome;
  final VoidCallback? onRequestInstallment;
  final VoidCallback onLoadMore;

  const TransactionsTable({
    super.key,
    required this.project,
    required this.transactions,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.totalCost,
    this.startDate,
    this.endDate,
    required this.isAddingExpense,
    this.isAddingIncome = false,
    required this.editingTransactions,
    required this.isLoadingMore,
    required this.hasMoreTransactions,
    required this.isSiteEngineer,
    required this.isAdminOrManager,
    required this.paymentSchedule,
    required this.pendingInstallmentRequests,
    required this.profitPercentage,
    this.onAddExpense,
    this.onAddIncome,
    this.onRequestInstallment,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              ExpenseSummaryStrip(
                totalReceived: totalReceived,
                totalExpenses: totalExpenses,
                netCashFlow: netCashFlow,
                totalCost: totalCost,
                startDate: startDate,
                endDate: endDate,
                isCompact: isCompact,
              ),
              const Divider(height: 1, color: AppColors.border),
              TransactionsTableHeader(
                onAddExpense: onAddExpense == null
                    ? null
                    : () => _showAddExpenseDialog(context),
                onAddIncome: onAddIncome == null
                    ? null
                    : () => _showAddIncomeDialog(context),
                isSiteEngineer: isSiteEngineer,
                isAdminOrManager: isAdminOrManager,
                isCompact: isCompact,
              ),
              const Divider(height: 1, color: AppColors.border),
              if (!isCompact) ...[
                const TransactionsColumnHeaders(),
                const Divider(height: 1, color: AppColors.border),
              ],
              ...transactions.map((transaction) {
                final isEditing = editingTransactions[transaction.id] ?? false;
                InstallmentRequestModel? pendingRequest;
                String? requestId = transaction.requestId;
                for (final request in pendingInstallmentRequests) {
                  if (request.id == requestId) {
                    pendingRequest = request;
                    break;
                  }
                }
                if (pendingRequest == null) {
                  for (final request in pendingInstallmentRequests) {
                    if (request.phaseName == transaction.description ||
                        request.phaseName == transaction.subDescription) {
                      pendingRequest = request;
                      break;
                    }
                  }
                }
                requestId ??= pendingRequest?.id;
                final installmentRequestId = requestId ?? transaction.id;
                return TransactionRow(
                  projectId: project.id,
                  transaction: transaction,
                  isEditing: isEditing,
                  isCompact: isCompact,
                  isAdminOrManager: isAdminOrManager,
                  installmentRequestId: installmentRequestId,
                );
              }),
              if (hasMoreTransactions)
                LoadMoreButton(
                  isLoading: isLoadingMore,
                  onLoadMore: onLoadMore,
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final cubit = context.read<ExecutionCubit>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: AddExpenseRow(
            projectId: project.id,
            onCancel: () => Navigator.of(dialogContext).pop(),
            isCompact: true,
            cubit: cubit,
          ),
        ),
      ),
    );
  }

  void _showAddIncomeDialog(BuildContext context) {
    final cubit = context.read<ExecutionCubit>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: AddIncomeRow(
            projectId: project.id,
            onCancel: () => Navigator.of(dialogContext).pop(),
            isCompact: true,
            cubit: cubit,
          ),
        ),
      ),
    );
  }
}
