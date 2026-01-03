import 'package:equatable/equatable.dart';

/// Financial summary for a project
class ProjectFinancialSummary extends Equatable {
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final double? budget;
  final double? remainingBudget;
  final double? budgetPercentage;

  const ProjectFinancialSummary({
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    this.budget,
    this.remainingBudget,
    this.budgetPercentage,
  });

  @override
  List<Object?> get props => [
        totalReceived,
        totalExpenses,
        netCashFlow,
        budget,
        remainingBudget,
        budgetPercentage,
      ];

  /// Create a copy with updated fields
  ProjectFinancialSummary copyWith({
    double? totalReceived,
    double? totalExpenses,
    double? netCashFlow,
    double? budget,
    double? remainingBudget,
    double? budgetPercentage,
  }) {
    return ProjectFinancialSummary(
      totalReceived: totalReceived ?? this.totalReceived,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netCashFlow: netCashFlow ?? this.netCashFlow,
      budget: budget ?? this.budget,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      budgetPercentage: budgetPercentage ?? this.budgetPercentage,
    );
  }

  /// Create empty summary
  factory ProjectFinancialSummary.empty() {
    return const ProjectFinancialSummary(
      totalReceived: 0.0,
      totalExpenses: 0.0,
      netCashFlow: 0.0,
    );
  }
}

