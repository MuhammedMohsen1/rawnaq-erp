import 'package:equatable/equatable.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';

/// Base class for all project events
abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

/// Load projects with optional filters
class LoadProjects extends ProjectsEvent {
  final ProjectStatus? status;
  final String? managerId;
  final String? teamMemberId;
  final String? searchQuery;
  final int? page;
  final int? limit;

  const LoadProjects({
    this.status,
    this.managerId,
    this.teamMemberId,
    this.searchQuery,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [
        status,
        managerId,
        teamMemberId,
        searchQuery,
        page,
        limit,
      ];
}

/// Refresh projects list
class RefreshProjects extends ProjectsEvent {
  const RefreshProjects();
}

/// Search projects by query
class SearchProjects extends ProjectsEvent {
  final String query;

  const SearchProjects(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter projects by status
class FilterByStatus extends ProjectsEvent {
  final ProjectStatus? status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filter projects by manager
class FilterByManager extends ProjectsEvent {
  final String? managerId;

  const FilterByManager(this.managerId);

  @override
  List<Object?> get props => [managerId];
}

/// Filter projects by team member
class FilterByTeamMember extends ProjectsEvent {
  final String? teamMemberId;

  const FilterByTeamMember(this.teamMemberId);

  @override
  List<Object?> get props => [teamMemberId];
}

/// Clear all filters
class ClearFilters extends ProjectsEvent {
  const ClearFilters();
}

/// Create a new project
class CreateProject extends ProjectsEvent {
  final ProjectEntity project;

  const CreateProject(this.project);

  @override
  List<Object?> get props => [project];
}

/// Create a new project with full data
class CreateProjectWithData extends ProjectsEvent {
  final String name;
  final String? description;
  final String type; // 'DESIGN' or 'EXECUTION'
  final String primaryDepartmentId;
  final String? clientName;
  final String? clientPhone;
  final String? clientEmail;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? deadline;
  final int progress;

  const CreateProjectWithData({
    required this.name,
    this.description,
    required this.type,
    required this.primaryDepartmentId,
    this.clientName,
    this.clientPhone,
    this.clientEmail,
    this.startDate,
    this.endDate,
    this.deadline,
    this.progress = 0,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        type,
        primaryDepartmentId,
        clientName,
        clientPhone,
        clientEmail,
        startDate,
        endDate,
        deadline,
        progress,
      ];
}

/// Update an existing project
class UpdateProject extends ProjectsEvent {
  final ProjectEntity project;

  const UpdateProject(this.project);

  @override
  List<Object?> get props => [project];
}

/// Delete a project
class DeleteProject extends ProjectsEvent {
  final String projectId;

  const DeleteProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Load team members
class LoadTeamMembers extends ProjectsEvent {
  const LoadTeamMembers();
}

/// Load project statistics
class LoadStatistics extends ProjectsEvent {
  const LoadStatistics();
}

/// Change view mode (table/cards)
class ChangeViewMode extends ProjectsEvent {
  final bool isTableView;

  const ChangeViewMode(this.isTableView);

  @override
  List<Object?> get props => [isTableView];
}

