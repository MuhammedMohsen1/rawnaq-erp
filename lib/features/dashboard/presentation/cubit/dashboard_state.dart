part of 'dashboard_cubit.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  final DashboardSummaryModel summary;
  const DashboardLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

final class DashboardFailure extends DashboardState {
  final String message;
  const DashboardFailure(this.message);
  @override
  List<Object?> get props => [message];
}
