import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/financial_api_datasource.dart';
import '../../data/models/project_financial_overview_model.dart';

sealed class ProjectFinancialOverviewState {
  const ProjectFinancialOverviewState();
}

final class ProjectFinancialOverviewLoading
    extends ProjectFinancialOverviewState {
  const ProjectFinancialOverviewLoading();
}

final class ProjectFinancialOverviewFailure
    extends ProjectFinancialOverviewState {
  final String message;
  const ProjectFinancialOverviewFailure(this.message);
}

final class ProjectFinancialOverviewLoaded
    extends ProjectFinancialOverviewState {
  final ProjectFinancialOverviewModel overview;
  const ProjectFinancialOverviewLoaded(this.overview);
}

class ProjectFinancialOverviewCubit
    extends Cubit<ProjectFinancialOverviewState> {
  final FinancialApiDataSource dataSource;
  ProjectFinancialOverviewCubit({FinancialApiDataSource? dataSource})
    : dataSource = dataSource ?? FinancialApiDataSource(),
      super(const ProjectFinancialOverviewLoading());
  Future<void> load(String projectId) async {
    emit(const ProjectFinancialOverviewLoading());
    try {
      emit(
        ProjectFinancialOverviewLoaded(
          await dataSource.getProjectOverview(projectId),
        ),
      );
    } catch (error) {
      emit(ProjectFinancialOverviewFailure(error.toString()));
    }
  }
}
