import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/financial_api_datasource.dart';
import 'financial_state.dart';

class FinancialCubit extends Cubit<FinancialState> {
  final FinancialApiDataSource apiDataSource;

  FinancialCubit({required this.apiDataSource})
    : super(const FinancialInitial());

  Future<void> loadSummary() async {
    emit(const FinancialLoading());
    try {
      final summary = await apiDataSource.getSummary();
      emit(FinancialLoaded(summary: summary));
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
}
