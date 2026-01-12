import 'package:equatable/equatable.dart';
import '../../data/models/execution_models.dart';

sealed class ExecutionState extends Equatable {
  const ExecutionState();

  @override
  List<Object?> get props => [];
}

class ExecutionInitial extends ExecutionState {
  const ExecutionInitial();
}

class ExecutionLoading extends ExecutionState {
  const ExecutionLoading();
}

class ExecutionLoaded extends ExecutionState {
  final ExecutionDashboardModel dashboard;
  final bool isAddingExpense;
  final bool isAddingIncome;
  final Map<String, bool> editingTransactions;
  final bool isLoadingMore;
  final String? editingExpenseId;

  const ExecutionLoaded({
    required this.dashboard,
    this.isAddingExpense = false,
    this.isAddingIncome = false,
    this.editingTransactions = const {},
    this.isLoadingMore = false,
    this.editingExpenseId,
  });

  @override
  List<Object?> get props => [
        dashboard,
        isAddingExpense,
        isAddingIncome,
        editingTransactions,
        isLoadingMore,
        editingExpenseId,
      ];

  ExecutionLoaded copyWith({
    ExecutionDashboardModel? dashboard,
    bool? isAddingExpense,
    bool? isAddingIncome,
    Map<String, bool>? editingTransactions,
    bool? isLoadingMore,
    String? editingExpenseId,
    bool clearEditingExpenseId = false,
  }) {
    return ExecutionLoaded(
      dashboard: dashboard ?? this.dashboard,
      isAddingExpense: isAddingExpense ?? this.isAddingExpense,
      isAddingIncome: isAddingIncome ?? this.isAddingIncome,
      editingTransactions: editingTransactions ?? this.editingTransactions,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      editingExpenseId: clearEditingExpenseId ? null : (editingExpenseId ?? this.editingExpenseId),
    );
  }
}

class ExecutionError extends ExecutionState {
  final String message;

  const ExecutionError({required this.message});

  @override
  List<Object?> get props => [message];
}
