import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/financial_api_datasource.dart';
import 'financial_state.dart';

class FinancialCubit extends Cubit<FinancialState> {
  final FinancialApiDataSource apiDataSource;

  FinancialCubit({required this.apiDataSource})
    : super(const FinancialInitial());

  Future<void> loadSummary({
    String? period,
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
    emit(const FinancialLoading());
    try {
      final summary = await apiDataSource.getSummary(
        period: selectedPeriod,
        startDate: selectedRange?.start,
        endDate: selectedRange?.end,
      );
      emit(
        FinancialLoaded(
          summary: summary,
          searchQuery: previous?.searchQuery ?? '',
          period: selectedPeriod,
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
      loadSummary(period: period, resetFilter: period == null);

  Future<void> selectCustomRange(DateTimeRange range) =>
      loadSummary(customRange: range);
}
