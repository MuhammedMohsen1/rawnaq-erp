import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/execution_api_datasource.dart';
import '../../data/models/execution_models.dart';
import 'execution_state.dart';

class ExecutionCubit extends Cubit<ExecutionState> {
  final ExecutionApiDataSource _apiDataSource;

  ExecutionCubit({ExecutionApiDataSource? apiDataSource})
      : _apiDataSource = apiDataSource ?? ExecutionApiDataSource(),
        super(const ExecutionInitial());

  /// Load execution dashboard data
  Future<void> loadDashboard(String projectId) async {
    emit(const ExecutionLoading());
    try {
      final dashboard = await _apiDataSource.getExecutionDashboard(projectId);
      emit(ExecutionLoaded(dashboard: dashboard));
    } catch (e) {
      emit(ExecutionError(message: 'فشل تحميل بيانات التنفيذ: ${e.toString()}'));
    }
  }

  /// Refresh dashboard without showing loading state
  Future<void> refreshDashboard(String projectId) async {
    final currentState = state;
    try {
      final dashboard = await _apiDataSource.getExecutionDashboard(projectId);
      if (currentState is ExecutionLoaded) {
        emit(currentState.copyWith(dashboard: dashboard));
      } else {
        emit(ExecutionLoaded(dashboard: dashboard));
      }
    } catch (e) {
      // Keep current state on error during refresh
      if (currentState is! ExecutionLoaded) {
        emit(ExecutionError(message: 'فشل تحديث البيانات: ${e.toString()}'));
      }
    }
  }

  /// Add new expense
  Future<void> addExpense(String projectId, CreateExpenseDto dto) async {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;

    try {
      await _apiDataSource.createExpense(projectId, dto);
      emit(currentState.copyWith(isAddingExpense: false));
      await refreshDashboard(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Update expense (inline edit)
  Future<void> updateExpense(
    String projectId,
    String expenseId,
    UpdateExpenseDto dto,
  ) async {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;

    try {
      await _apiDataSource.updateExpense(projectId, expenseId, dto);
      // Clear editing state
      final newEditingStates = Map<String, bool>.from(currentState.editingTransactions);
      newEditingStates.remove(expenseId);
      emit(currentState.copyWith(
        editingTransactions: newEditingStates,
        clearEditingExpenseId: true,
      ));
      await refreshDashboard(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete expense
  Future<void> deleteExpense(String projectId, String expenseId) async {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;

    try {
      await _apiDataSource.deleteExpense(projectId, expenseId);
      await refreshDashboard(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Request installment (Site Engineer)
  Future<void> requestInstallment(
    String projectId, {
    required int phaseIndex,
    required String phaseName,
  }) async {
    try {
      await _apiDataSource.requestInstallment(
        projectId,
        phaseIndex: phaseIndex,
        phaseName: phaseName,
      );
      await refreshDashboard(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Approve installment (Admin/Manager)
  Future<void> approveInstallment(String projectId, String requestId) async {
    try {
      await _apiDataSource.approveInstallment(requestId);
      await refreshDashboard(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Reject installment (Admin/Manager)
  Future<void> rejectInstallment(
    String projectId,
    String requestId, {
    required String reason,
  }) async {
    try {
      await _apiDataSource.rejectInstallment(requestId, reason: reason);
      await refreshDashboard(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Load more transactions
  Future<void> loadMoreTransactions(String projectId) async {
    final currentState = state;
    if (currentState is! ExecutionLoaded || currentState.isLoadingMore) return;
    if (!currentState.dashboard.hasMoreTransactions) return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final currentCount = currentState.dashboard.transactions.length;
      final nextPage = (currentCount / 20).ceil() + 1;
      final moreTransactions = await _apiDataSource.getTransactions(
        projectId,
        page: nextPage,
        limit: 20,
      );

      final updatedDashboard = currentState.dashboard.copyWith(
        transactions: [...currentState.dashboard.transactions, ...moreTransactions],
        hasMoreTransactions: moreTransactions.length >= 20,
      );

      emit(currentState.copyWith(
        dashboard: updatedDashboard,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// Start adding new expense (show empty row)
  void startAddingExpense() {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;
    emit(currentState.copyWith(isAddingExpense: true));
  }

  /// Cancel adding expense
  void cancelAddingExpense() {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;
    emit(currentState.copyWith(isAddingExpense: false));
  }

  /// Start adding new income (show empty row - Admin/Manager only)
  void startAddingIncome() {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;
    emit(currentState.copyWith(isAddingIncome: true, isAddingExpense: false));
  }

  /// Cancel adding income
  void cancelAddingIncome() {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;
    emit(currentState.copyWith(isAddingIncome: false));
  }

  /// Add new income (Admin/Manager direct income addition)
  Future<void> addIncome(String projectId, CreateIncomeDto dto) async {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;

    try {
      await _apiDataSource.createIncome(projectId, dto);
      emit(currentState.copyWith(isAddingIncome: false));
      await refreshDashboard(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle inline editing mode for a transaction
  void toggleEditing(String transactionId) {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;

    final newEditingStates = Map<String, bool>.from(currentState.editingTransactions);
    final isCurrentlyEditing = newEditingStates[transactionId] ?? false;

    if (isCurrentlyEditing) {
      newEditingStates.remove(transactionId);
      emit(currentState.copyWith(
        editingTransactions: newEditingStates,
        clearEditingExpenseId: true,
      ));
    } else {
      // Clear all other editing states and set this one
      newEditingStates.clear();
      newEditingStates[transactionId] = true;
      emit(currentState.copyWith(
        editingTransactions: newEditingStates,
        editingExpenseId: transactionId,
        isAddingExpense: false, // Close new expense row if open
      ));
    }
  }

  /// Cancel editing for a specific transaction
  void cancelEditing(String transactionId) {
    final currentState = state;
    if (currentState is! ExecutionLoaded) return;

    final newEditingStates = Map<String, bool>.from(currentState.editingTransactions);
    newEditingStates.remove(transactionId);
    emit(currentState.copyWith(
      editingTransactions: newEditingStates,
      clearEditingExpenseId: true,
    ));
  }
}
