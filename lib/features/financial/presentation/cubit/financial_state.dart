import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../data/models/financial_summary_model.dart';

sealed class FinancialState extends Equatable {
  const FinancialState();

  @override
  List<Object?> get props => [];
}

final class FinancialInitial extends FinancialState {
  const FinancialInitial();
}

final class FinancialLoading extends FinancialState {
  const FinancialLoading();
}

final class FinancialLoaded extends FinancialState {
  final FinancialSummaryModel summary;
  final List<CompanyExpenseModel> companyExpenses;
  final String searchQuery;
  final String? period;
  final String? projectType;
  final DateTimeRange? customRange;
  final bool companyExpensesLoading;
  final bool companyExpenseSaving;

  const FinancialLoaded({
    required this.summary,
    this.companyExpenses = const [],
    this.searchQuery = '',
    this.period,
    this.projectType,
    this.customRange,
    this.companyExpensesLoading = false,
    this.companyExpenseSaving = false,
  });

  List<FinancialProjectModel> get filteredProjects {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return summary.projects;

    return summary.projects.where((project) {
      return project.projectName.toLowerCase().contains(query) ||
          (project.clientName ?? '').toLowerCase().contains(query) ||
          project.status.toLowerCase().contains(query) ||
          (project.projectType ?? '').toLowerCase().contains(query);
    }).toList();
  }

  FinancialLoaded copyWith({
    FinancialSummaryModel? summary,
    List<CompanyExpenseModel>? companyExpenses,
    String? searchQuery,
    String? period,
    String? projectType,
    DateTimeRange? customRange,
    bool? companyExpensesLoading,
    bool? companyExpenseSaving,
    bool clearPeriod = false,
    bool clearProjectType = false,
    bool clearCustomRange = false,
  }) {
    return FinancialLoaded(
      summary: summary ?? this.summary,
      companyExpenses: companyExpenses ?? this.companyExpenses,
      searchQuery: searchQuery ?? this.searchQuery,
      period: clearPeriod ? null : period ?? this.period,
      projectType: clearProjectType ? null : projectType ?? this.projectType,
      customRange: clearCustomRange ? null : customRange ?? this.customRange,
      companyExpensesLoading:
          companyExpensesLoading ?? this.companyExpensesLoading,
      companyExpenseSaving: companyExpenseSaving ?? this.companyExpenseSaving,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    companyExpenses,
    searchQuery,
    period,
    projectType,
    customRange,
    companyExpensesLoading,
    companyExpenseSaving,
  ];
}

final class FinancialFailure extends FinancialState {
  final String message;

  const FinancialFailure(this.message);

  @override
  List<Object?> get props => [message];
}
