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
  final String searchQuery;
  final String? period;
  final DateTimeRange? customRange;

  const FinancialLoaded({
    required this.summary,
    this.searchQuery = '',
    this.period,
    this.customRange,
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
    String? searchQuery,
    String? period,
    DateTimeRange? customRange,
    bool clearPeriod = false,
    bool clearCustomRange = false,
  }) {
    return FinancialLoaded(
      summary: summary ?? this.summary,
      searchQuery: searchQuery ?? this.searchQuery,
      period: clearPeriod ? null : period ?? this.period,
      customRange: clearCustomRange ? null : customRange ?? this.customRange,
    );
  }

  @override
  List<Object?> get props => [summary, searchQuery, period, customRange];
}

final class FinancialFailure extends FinancialState {
  final String message;

  const FinancialFailure(this.message);

  @override
  List<Object?> get props => [message];
}
