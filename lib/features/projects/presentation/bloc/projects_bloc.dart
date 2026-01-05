import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/projects_repository.dart';
import '../../data/repositories/projects_repository_impl.dart';
import 'projects_event.dart';
import 'projects_state.dart';

/// BLoC for managing projects state
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectsRepository _repository;

  ProjectsBloc({required ProjectsRepository repository})
      : _repository = repository,
        super(const ProjectsInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<RefreshProjects>(_onRefreshProjects);
    on<SearchProjects>(_onSearchProjects);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByManager>(_onFilterByManager);
    on<FilterByTeamMember>(_onFilterByTeamMember);
    on<ClearFilters>(_onClearFilters);
    on<CreateProject>(_onCreateProject);
    on<CreateProjectWithData>(_onCreateProjectWithData);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<LoadTeamMembers>(_onLoadTeamMembers);
    on<LoadStatistics>(_onLoadStatistics);
    on<ChangeViewMode>(_onChangeViewMode);
  }

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(const ProjectsLoading());

    final result = await _repository.getProjects(
      status: event.status,
      managerId: event.managerId,
      teamMemberId: event.teamMemberId,
      searchQuery: event.searchQuery,
    );

    await result.fold(
      (failure) async {
        emit(ProjectsError(message: failure.message));
      },
      (projects) async {
        // Also load team members and statistics
        final teamMembersResult = await _repository.getTeamMembers();
        final statisticsResult = await _repository.getProjectStatistics();

        final teamMembers = teamMembersResult.fold(
          (failure) => <dynamic>[],
          (members) => members,
        );

        final statistics = statisticsResult.fold(
          (failure) => null,
          (stats) => stats,
        );

        emit(ProjectsLoaded(
          projects: projects,
          filteredProjects: projects,
          teamMembers: teamMembers.cast(),
          statistics: statistics,
          statusFilter: event.status,
          managerFilter: event.managerId,
          teamMemberFilter: event.teamMemberId,
          searchQuery: event.searchQuery,
        ));
      },
    );
  }

  Future<void> _onRefreshProjects(
    RefreshProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      add(LoadProjects(
        status: currentState.statusFilter,
        managerId: currentState.managerFilter,
        teamMemberId: currentState.teamMemberFilter,
        searchQuery: currentState.searchQuery,
      ));
    } else {
      add(const LoadProjects());
    }
  }

  Future<void> _onSearchProjects(
    SearchProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      
      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          filteredProjects: currentState.projects,
          clearSearchQuery: true,
        ));
      } else {
        final query = event.query.toLowerCase();
        final filtered = currentState.projects.where((project) {
          return project.name.toLowerCase().contains(query) ||
              (project.description?.toLowerCase().contains(query) ?? false);
        }).toList();

        emit(currentState.copyWith(
          filteredProjects: filtered,
          searchQuery: event.query,
        ));
      }
    }
  }

  Future<void> _onFilterByStatus(
    FilterByStatus event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      
      add(LoadProjects(
        status: event.status,
        managerId: currentState.managerFilter,
        teamMemberId: currentState.teamMemberFilter,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  Future<void> _onFilterByManager(
    FilterByManager event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      
      add(LoadProjects(
        status: currentState.statusFilter,
        managerId: event.managerId,
        teamMemberId: currentState.teamMemberFilter,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  Future<void> _onFilterByTeamMember(
    FilterByTeamMember event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      
      add(LoadProjects(
        status: currentState.statusFilter,
        managerId: currentState.managerFilter,
        teamMemberId: event.teamMemberId,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<ProjectsState> emit,
  ) async {
    add(const LoadProjects());
  }

  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(ProjectsOperationInProgress(currentState));

      final result = await _repository.createProject(event.project);

      result.fold(
        (failure) {
          emit(ProjectsError(
            message: failure.message,
            previousState: currentState,
          ));
        },
        (project) {
          emit(ProjectCreated(
            project: project,
            previousState: currentState,
          ));
          // Refresh the list
          add(const RefreshProjects());
        },
      );
    }
  }

  Future<void> _onCreateProjectWithData(
    CreateProjectWithData event,
    Emitter<ProjectsState> emit,
  ) async {
    // If not loaded, load projects first
    if (state is! ProjectsLoaded) {
      emit(const ProjectsLoading());
      final loadResult = await _repository.getProjects();
      
      await loadResult.fold(
        (failure) async {
          emit(ProjectsError(message: failure.message));
        },
        (projects) async {
          final teamMembersResult = await _repository.getTeamMembers();
          final statisticsResult = await _repository.getProjectStatistics();

          final teamMembers = teamMembersResult.fold(
            (failure) => <dynamic>[],
            (members) => members,
          );

          final statistics = statisticsResult.fold(
            (failure) => null,
            (stats) => stats,
          );

          emit(ProjectsLoaded(
            projects: projects,
            filteredProjects: projects,
            teamMembers: teamMembers.cast(),
            statistics: statistics,
          ));
        },
      );
    }

    // Now proceed with creating the project
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(ProjectsOperationInProgress(currentState));

      final repository = _repository as ProjectsRepositoryImpl;
      final result = await repository.createProjectWithData(
        name: event.name,
        description: event.description,
        type: event.type,
        primaryDepartmentId: event.primaryDepartmentId,
        clientName: event.clientName,
        clientPhone: event.clientPhone,
        clientEmail: event.clientEmail,
        startDate: event.startDate,
        endDate: event.endDate,
        deadline: event.deadline,
        progress: event.progress,
      );

      result.fold(
        (failure) {
          emit(ProjectsError(
            message: failure.message,
            previousState: currentState,
          ));
        },
        (project) {
          emit(ProjectCreated(
            project: project,
            previousState: currentState,
          ));
          // Refresh the list
          add(const RefreshProjects());
        },
      );
    }
  }

  Future<void> _onUpdateProject(
    UpdateProject event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(ProjectsOperationInProgress(currentState));

      final result = await _repository.updateProject(event.project);

      result.fold(
        (failure) {
          emit(ProjectsError(
            message: failure.message,
            previousState: currentState,
          ));
        },
        (project) {
          emit(ProjectUpdated(
            project: project,
            previousState: currentState,
          ));
          // Refresh the list
          add(const RefreshProjects());
        },
      );
    }
  }

  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(ProjectsOperationInProgress(currentState));

      final result = await _repository.deleteProject(event.projectId);

      result.fold(
        (failure) {
          emit(ProjectsError(
            message: failure.message,
            previousState: currentState,
          ));
        },
        (_) {
          emit(ProjectDeleted(
            projectId: event.projectId,
            previousState: currentState,
          ));
          // Refresh the list
          add(const RefreshProjects());
        },
      );
    }
  }

  Future<void> _onLoadTeamMembers(
    LoadTeamMembers event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      
      final result = await _repository.getTeamMembers();
      
      result.fold(
        (failure) {
          // Keep current state, just log error
        },
        (members) {
          emit(currentState.copyWith(teamMembers: members));
        },
      );
    }
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      
      final result = await _repository.getProjectStatistics();
      
      result.fold(
        (failure) {
          // Keep current state, just log error
        },
        (stats) {
          emit(currentState.copyWith(statistics: stats));
        },
      );
    }
  }

  void _onChangeViewMode(
    ChangeViewMode event,
    Emitter<ProjectsState> emit,
  ) {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(currentState.copyWith(isTableView: event.isTableView));
    }
  }
}

