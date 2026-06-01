import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/dashboard_api_datasource.dart';
import '../../data/models/dashboard_summary_model.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardApiDataSource dataSource;
  DashboardCubit({required this.dataSource}) : super(const DashboardInitial());
  Future<void> load({String period = 'YEAR'}) async {
    emit(const DashboardLoading());
    try {
      emit(DashboardLoaded(await dataSource.getSummary(period)));
    } catch (error) {
      emit(DashboardFailure(error.toString()));
    }
  }

  Future<void> changePeriod(String period) => load(period: period);
}
