import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/entities/project_financial_summary.dart';
import '../../../financial/domain/repositories/transactions_repository.dart';
import '../../domain/repositories/projects_repository.dart';
import 'project_financial_state.dart';

/// Cubit for managing project financial state
class ProjectFinancialCubit extends Cubit<ProjectFinancialState> {
  final ProjectsRepository projectsRepository;
  final TransactionsRepository transactionsRepository;

  ProjectFinancialCubit({
    required this.projectsRepository,
    required this.transactionsRepository,
  }) : super(const ProjectFinancialInitial());

  /// Load project financial data
  Future<void> loadProjectFinancialData(String projectId) async {
    emit(const ProjectFinancialLoading());

    try {
      // Load project
      final projectResult = await projectsRepository.getProjectById(projectId);

      // Load transactions
      final transactionsResult =
          await transactionsRepository.getTransactionsByProjectId(projectId);

      // Load financial summary
      final summaryResult =
          await transactionsRepository.getProjectFinancialSummary(projectId);

      // Check if project exists
      final project = projectResult.fold(
        (failure) => null,
        (project) => project,
      );

      if (project == null) {
        emit(const ProjectFinancialNotFound());
        return;
      }

      // Get transactions
      final transactions = transactionsResult.fold(
        (failure) {
          emit(ProjectFinancialError(message: failure.message));
          return <TransactionEntity>[];
        },
        (transactions) => transactions,
      );

      // Get financial summary
      final summary = summaryResult.fold(
        (failure) {
          emit(ProjectFinancialError(message: failure.message));
          return null;
        },
        (summary) => summary,
      );

      if (summary != null) {
        emit(ProjectFinancialLoaded(
          project: project,
          transactions: transactions,
          financialSummary: summary,
        ));
      }
    } catch (e) {
      emit(ProjectFinancialError(
        message: 'فشل تحميل البيانات المالية: ${e.toString()}',
      ));
    }
  }

  /// Add a new transaction
  void addTransaction(TransactionEntity transaction) {
    final currentState = state;
    if (currentState is! ProjectFinancialLoaded) return;

    final updatedTransactions = [transaction, ...currentState.transactions];
    final updatedSummary = _recalculateSummary(updatedTransactions);

    emit(currentState.copyWith(
      transactions: updatedTransactions,
      financialSummary: updatedSummary,
    ));
  }

  /// Update an existing transaction
  void updateTransaction(TransactionEntity transaction) {
    final currentState = state;
    if (currentState is! ProjectFinancialLoaded) return;

    final updatedTransactions = currentState.transactions.map((t) {
      return t.id == transaction.id ? transaction : t;
    }).toList();

    final updatedSummary = _recalculateSummary(updatedTransactions);

    emit(currentState.copyWith(
      transactions: updatedTransactions,
      financialSummary: updatedSummary,
    ));
  }

  /// Delete a transaction
  void deleteTransaction(String transactionId) {
    final currentState = state;
    if (currentState is! ProjectFinancialLoaded) return;

    final updatedTransactions = currentState.transactions
        .where((t) => t.id != transactionId)
        .toList();

    final updatedSummary = _recalculateSummary(updatedTransactions);

    emit(currentState.copyWith(
      transactions: updatedTransactions,
      financialSummary: updatedSummary,
    ));
  }

  /// Recalculate financial summary based on transactions
  ProjectFinancialSummary _recalculateSummary(
    List<TransactionEntity> transactions,
  ) {
    double totalReceived = 0.0;
    double totalExpenses = 0.0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.deposit) {
        totalReceived += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    final netCashFlow = totalReceived - totalExpenses;

    // Calculate budget percentage (assuming a budget of 50,000)
    const double budget = 50000.0;
    final remainingBudget = budget - totalExpenses;
    final budgetPercentage =
        budget > 0 ? (remainingBudget / budget) * 100 : 0.0;

    return ProjectFinancialSummary(
      totalReceived: totalReceived,
      totalExpenses: totalExpenses,
      netCashFlow: netCashFlow,
      budget: budget,
      remainingBudget: remainingBudget,
      budgetPercentage: budgetPercentage,
    );
  }
}
