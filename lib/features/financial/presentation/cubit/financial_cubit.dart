import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/financial_api_datasource.dart';
import 'financial_state.dart';

class FinancialCubit extends Cubit<FinancialState> {
  final FinancialApiDataSource apiDataSource;

  FinancialCubit({required this.apiDataSource})
    : super(const FinancialInitial());

  Future<void> loadInitial({required bool includeCompanyExpenses}) async {
    await loadSummary(period: 'MONTH');
    if (includeCompanyExpenses) {
      await loadCompanyExpenses();
    }
  }

  Future<void> loadSummary({
    String? period,
    String? projectType,
    DateTimeRange? customRange,
    bool resetFilter = false,
  }) async {
    final previous = state is FinancialLoaded ? state as FinancialLoaded : null;
    final selectedPeriod = resetFilter
        ? null
        : customRange != null
        ? null
        : period ?? previous?.period;
    final selectedRange = resetFilter
        ? null
        : customRange ?? (period != null ? null : previous?.customRange);
    final selectedProjectType = resetFilter
        ? null
        : projectType ?? previous?.projectType;
    emit(const FinancialLoading());
    try {
      final summary = await apiDataSource.getSummary(
        period: selectedPeriod,
        projectType: selectedProjectType,
        startDate: selectedRange?.start,
        endDate: selectedRange?.end,
      );
      emit(
        FinancialLoaded(
          summary: summary,
          companyExpenses: previous?.companyExpenses ?? const [],
          searchQuery: previous?.searchQuery ?? '',
          period: selectedPeriod,
          projectType: selectedProjectType,
          customRange: selectedRange,
        ),
      );
    } catch (error) {
      emit(FinancialFailure(error.toString()));
    }
  }

  void updateSearchQuery(String query) {
    final state = this.state;
    if (state is FinancialLoaded) {
      emit(state.copyWith(searchQuery: query));
    }
  }

  Future<void> selectPeriod(String? period) =>
      _reloadWithCompanyExpenses(period: period, resetFilter: period == null);

  Future<void> selectCustomRange(DateTimeRange range) =>
      _reloadWithCompanyExpenses(customRange: range);

  Future<void> selectProjectType(String? projectType) =>
      loadSummary(projectType: projectType);

  Future<void> _reloadWithCompanyExpenses({
    String? period,
    DateTimeRange? customRange,
    bool resetFilter = false,
  }) async {
    await loadSummary(
      period: period,
      customRange: customRange,
      resetFilter: resetFilter,
    );
    await loadCompanyExpenses();
  }

  Future<void> loadCompanyExpenses() async {
    final current = state;
    if (current is! FinancialLoaded) return;
    emit(current.copyWith(companyExpensesLoading: true));
    try {
      final expenses = await apiDataSource.getCompanyExpenses(
        period: current.period,
        startDate: current.customRange?.start,
        endDate: current.customRange?.end,
      );
      final latest = state;
      if (latest is FinancialLoaded) {
        emit(
          latest.copyWith(
            companyExpenses: expenses,
            companyExpensesLoading: false,
          ),
        );
      }
    } catch (_) {
      final latest = state;
      if (latest is FinancialLoaded) {
        emit(latest.copyWith(companyExpensesLoading: false));
      }
    }
  }

  Future<void> saveCompanyExpense({
    String? id,
    required String title,
    String? description,
    String? category,
    required double amount,
    required DateTime transactionDate,
  }) async {
    final current = state;
    if (current is! FinancialLoaded) return;
    emit(current.copyWith(companyExpenseSaving: true));
    try {
      if (id == null) {
        await apiDataSource.createCompanyExpense(
          title: title,
          description: description,
          category: category,
          amount: amount,
          transactionDate: transactionDate,
        );
      } else {
        await apiDataSource.updateCompanyExpense(
          id: id,
          title: title,
          description: description,
          category: category,
          amount: amount,
          transactionDate: transactionDate,
        );
      }
      await loadSummary();
      await loadCompanyExpenses();
    } catch (error) {
      emit(FinancialFailure(error.toString()));
    }
  }

  Future<void> deleteCompanyExpense(String id) async {
    final current = state;
    if (current is! FinancialLoaded) return;
    emit(current.copyWith(companyExpenseSaving: true));
    try {
      await apiDataSource.deleteCompanyExpense(id);
      await loadSummary();
      await loadCompanyExpenses();
    } catch (error) {
      emit(FinancialFailure(error.toString()));
    }
  }
}
