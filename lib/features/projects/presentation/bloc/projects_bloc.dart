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
    on<LoadMoreProjects>(_onLoadMoreProjects);
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
    on<RestoreProject>(_onRestoreProject);
    on<UpdateProjectStatus>(_onUpdateProjectStatus);
    on<LoadTeamMembers>(_onLoadTeamMembers);
    on<LoadStatistics>(_onLoadStatistics);
    on<ChangeViewMode>(_onChangeViewMode);
  }

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(const ProjectsLoading());

    final requestedPage = event.page ?? 1;
    final requestedLimit = event.limit ?? 10;
    final result = await _repository.getProjects(
      status: event.status,
      type: event.type,
      managerId: event.managerId,
      teamMemberId: event.teamMemberId,
      searchQuery: event.searchQuery,
      archived: event.archived,
      assignedToMe: event.assignedToMe,
      page: requestedPage,
      limit: requestedLimit,
    );

    await result.fold(
      (failure) async {
        emit(ProjectsError(message: failure.message));
      },
      (paginatedResult) async {
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

        emit(
          ProjectsLoaded(
            projects: paginatedResult.projects,
            filteredProjects: paginatedResult.projects,
            teamMembers: teamMembers.cast(),
            statistics: statistics,
            statusFilter: event.status,
            typeFilter: event.type,
            managerFilter: event.managerId,
            teamMemberFilter: event.teamMemberId,
            searchQuery: event.searchQuery,
            archived: event.archived,
            assignedToMe: event.assignedToMe,
            currentPage: paginatedResult.page,
            totalPages: paginatedResult.totalPages,
            totalItems: paginatedResult.total,
            pageSize: paginatedResult.limit,
            hasMore: paginatedResult.page < paginatedResult.totalPages,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreProjects(
    LoadMoreProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;

    final currentState = state as ProjectsLoaded;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await _repository.getProjects(
      status: currentState.statusFilter,
      type: currentState.typeFilter,
      managerId: currentState.managerFilter,
      teamMemberId: currentState.teamMemberFilter,
      searchQuery: currentState.searchQuery,
      archived: currentState.archived,
      assignedToMe: currentState.assignedToMe,
      page: nextPage,
      limit: currentState.pageSize,
    );

    result.fold(
      (failure) {
        emit(
          ProjectsError(message: failure.message, previousState: currentState),
        );
      },
      (paginatedResult) {
        final projects = [
          ...currentState.projects,
          ...paginatedResult.projects,
        ];
        emit(
          currentState.copyWith(
            projects: projects,
            filteredProjects: projects,
            currentPage: paginatedResult.page,
            totalPages: paginatedResult.totalPages,
            totalItems: paginatedResult.total,
            pageSize: paginatedResult.limit,
            hasMore: paginatedResult.page < paginatedResult.totalPages,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onRefreshProjects(
    RefreshProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      add(
        LoadProjects(
          status: currentState.statusFilter,
          type: currentState.typeFilter,
          managerId: currentState.managerFilter,
          teamMemberId: currentState.teamMemberFilter,
          searchQuery: currentState.searchQuery,
          archived: currentState.archived,
          assignedToMe: currentState.assignedToMe,
          page: currentState.currentPage,
          limit: currentState.pageSize,
        ),
      );
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
      final query = event.query.trim();

      add(
        LoadProjects(
          status: currentState.statusFilter,
          type: currentState.typeFilter,
          managerId: currentState.managerFilter,
          teamMemberId: currentState.teamMemberFilter,
          searchQuery: query.isEmpty ? null : query,
          archived: currentState.archived,
          assignedToMe: currentState.assignedToMe,
          page: 1,
          limit: currentState.pageSize,
        ),
      );
    }
  }

  Future<void> _onFilterByStatus(
    FilterByStatus event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;

      add(
        LoadProjects(
          status: event.status,
          type: currentState.typeFilter,
          managerId: currentState.managerFilter,
          teamMemberId: currentState.teamMemberFilter,
          searchQuery: currentState.searchQuery,
          archived: currentState.archived,
          assignedToMe: currentState.assignedToMe,
          page: 1,
          limit: currentState.pageSize,
        ),
      );
    }
  }

  Future<void> _onFilterByManager(
    FilterByManager event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;

      add(
        LoadProjects(
          status: currentState.statusFilter,
          type: currentState.typeFilter,
          managerId: event.managerId,
          teamMemberId: currentState.teamMemberFilter,
          searchQuery: currentState.searchQuery,
          archived: currentState.archived,
          assignedToMe: currentState.assignedToMe,
          page: 1,
          limit: currentState.pageSize,
        ),
      );
    }
  }

  Future<void> _onFilterByTeamMember(
    FilterByTeamMember event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;

      add(
        LoadProjects(
          status: currentState.statusFilter,
          type: currentState.typeFilter,
          managerId: currentState.managerFilter,
          teamMemberId: event.teamMemberId,
          searchQuery: currentState.searchQuery,
          archived: currentState.archived,
          assignedToMe: currentState.assignedToMe,
          page: 1,
          limit: currentState.pageSize,
        ),
      );
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      add(
        LoadProjects(
          type: currentState.typeFilter,
          archived: currentState.archived,
          assignedToMe: currentState.assignedToMe,
          page: 1,
          limit: currentState.pageSize,
        ),
      );
      return;
    }

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
          emit(
            ProjectsError(
              message: failure.message,
              previousState: currentState,
            ),
          );
        },
        (project) {
          emit(ProjectCreated(project: project, previousState: currentState));
          add(_reloadFromState(currentState));
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
        (paginatedResult) async {
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

          emit(
            ProjectsLoaded(
              projects: paginatedResult.projects,
              filteredProjects: paginatedResult.projects,
              teamMembers: teamMembers.cast(),
              statistics: statistics,
              archived: false,
              currentPage: paginatedResult.page,
              totalPages: paginatedResult.totalPages,
              totalItems: paginatedResult.total,
              pageSize: paginatedResult.limit,
            ),
          );
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
        clientContacts: event.clientContacts,
        clientEmail: event.clientEmail,
        googleMapLink: event.googleMapLink,
        startDate: event.startDate,
        endDate: event.endDate,
        deadline: event.deadline,
        progress: event.progress,
        projectValue: event.projectValue,
        installments: event.installments,
      );

      result.fold(
        (failure) {
          emit(
            ProjectsError(
              message: failure.message,
              previousState: currentState,
            ),
          );
        },
        (project) {
          emit(ProjectCreated(project: project, previousState: currentState));
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
          emit(
            ProjectsError(
              message: failure.message,
              previousState: currentState,
            ),
          );
        },
        (project) {
          emit(ProjectUpdated(project: project, previousState: currentState));
          add(_reloadFromState(currentState));
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
          emit(
            ProjectsError(
              message: failure.message,
              previousState: currentState,
            ),
          );
        },
        (_) {
          emit(
            ProjectDeleted(
              projectId: event.projectId,
              previousState: currentState,
            ),
          );
          add(_reloadFromState(currentState));
        },
      );
    }
  }

  Future<void> _onRestoreProject(
    RestoreProject event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(ProjectsOperationInProgress(currentState));

      final result = await _repository.restoreProject(event.projectId);

      result.fold(
        (failure) {
          emit(
            ProjectsError(
              message: failure.message,
              previousState: currentState,
            ),
          );
        },
        (project) {
          emit(ProjectUpdated(project: project, previousState: currentState));
          add(_reloadFromState(currentState));
        },
      );
    }
  }

  Future<void> _onUpdateProjectStatus(
    UpdateProjectStatus event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(ProjectsOperationInProgress(currentState));

      final result = await _repository.updateProjectStatus(
        event.projectId,
        event.status,
        notes: event.notes,
      );

      result.fold(
        (failure) {
          emit(
            ProjectsError(
              message: failure.message,
              previousState: currentState,
            ),
          );
        },
        (project) {
          emit(ProjectUpdated(project: project, previousState: currentState));
          add(
            LoadProjects(
              status: currentState.statusFilter,
              type: currentState.typeFilter,
              managerId: currentState.managerFilter,
              teamMemberId: currentState.teamMemberFilter,
              searchQuery: currentState.searchQuery,
              archived: currentState.archived,
              assignedToMe: currentState.assignedToMe,
              page: currentState.currentPage,
              limit: currentState.pageSize,
            ),
          );
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

  LoadProjects _reloadFromState(ProjectsLoaded state) {
    return LoadProjects(
      status: state.statusFilter,
      type: state.typeFilter,
      managerId: state.managerFilter,
      teamMemberId: state.teamMemberFilter,
      searchQuery: state.searchQuery,
      archived: state.archived,
      assignedToMe: state.assignedToMe,
      page: 1,
      limit: state.pageSize,
    );
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

  void _onChangeViewMode(ChangeViewMode event, Emitter<ProjectsState> emit) {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      emit(currentState.copyWith(isTableView: event.isTableView));
    }
  }
}
