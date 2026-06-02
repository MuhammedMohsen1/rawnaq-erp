import 'package:equatable/equatable.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/repositories/projects_repository.dart';

/// Base class for all project states
abstract class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

/// Loading state while fetching data
class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

/// State when projects are successfully loaded
class ProjectsLoaded extends ProjectsState {
  final List<ProjectEntity> projects;
  final List<ProjectEntity> filteredProjects;
  final List<TeamMemberEntity> teamMembers;
  final ProjectStatistics? statistics;
  final ProjectStatus? statusFilter;
  final String? typeFilter;
  final String? managerFilter;
  final String? teamMemberFilter;
  final String? searchQuery;
  final bool archived;
  final bool assignedToMe;
  final bool isTableView;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasMore;
  final bool isLoadingMore;

  const ProjectsLoaded({
    required this.projects,
    required this.filteredProjects,
    this.teamMembers = const [],
    this.statistics,
    this.statusFilter,
    this.typeFilter,
    this.managerFilter,
    this.teamMemberFilter,
    this.searchQuery,
    this.archived = false,
    this.assignedToMe = false,
    this.isTableView = true,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.pageSize = 10,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    projects,
    filteredProjects,
    teamMembers,
    statistics,
    statusFilter,
    typeFilter,
    managerFilter,
    teamMemberFilter,
    searchQuery,
    archived,
    assignedToMe,
    isTableView,
    currentPage,
    totalPages,
    totalItems,
    pageSize,
    hasMore,
    isLoadingMore,
  ];

  /// Create a copy with updated fields
  ProjectsLoaded copyWith({
    List<ProjectEntity>? projects,
    List<ProjectEntity>? filteredProjects,
    List<TeamMemberEntity>? teamMembers,
    ProjectStatistics? statistics,
    ProjectStatus? statusFilter,
    String? typeFilter,
    String? managerFilter,
    String? teamMemberFilter,
    String? searchQuery,
    bool? archived,
    bool? assignedToMe,
    bool? isTableView,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    int? pageSize,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearStatusFilter = false,
    bool clearTypeFilter = false,
    bool clearManagerFilter = false,
    bool clearTeamMemberFilter = false,
    bool clearSearchQuery = false,
  }) {
    return ProjectsLoaded(
      projects: projects ?? this.projects,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      teamMembers: teamMembers ?? this.teamMembers,
      statistics: statistics ?? this.statistics,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      managerFilter: clearManagerFilter
          ? null
          : (managerFilter ?? this.managerFilter),
      teamMemberFilter: clearTeamMemberFilter
          ? null
          : (teamMemberFilter ?? this.teamMemberFilter),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      archived: archived ?? this.archived,
      assignedToMe: assignedToMe ?? this.assignedToMe,
      isTableView: isTableView ?? this.isTableView,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// State when an operation is in progress (create, update, delete)
class ProjectsOperationInProgress extends ProjectsState {
  final ProjectsLoaded previousState;

  const ProjectsOperationInProgress(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

/// State when an error occurs
class ProjectsError extends ProjectsState {
  final String message;
  final ProjectsLoaded? previousState;

  const ProjectsError({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// State when a project is successfully created
class ProjectCreated extends ProjectsState {
  final ProjectEntity project;
  final ProjectsLoaded previousState;

  const ProjectCreated({required this.project, required this.previousState});

  @override
  List<Object?> get props => [project, previousState];
}

/// State when a project is successfully updated
class ProjectUpdated extends ProjectsState {
  final ProjectEntity project;
  final ProjectsLoaded previousState;

  const ProjectUpdated({required this.project, required this.previousState});

  @override
  List<Object?> get props => [project, previousState];
}

/// State when a project is successfully deleted
class ProjectDeleted extends ProjectsState {
  final String projectId;
  final ProjectsLoaded previousState;

  const ProjectDeleted({required this.projectId, required this.previousState});

  @override
  List<Object?> get props => [projectId, previousState];
}
