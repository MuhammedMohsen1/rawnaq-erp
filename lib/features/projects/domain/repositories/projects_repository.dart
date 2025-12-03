import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project_entity.dart';
import '../entities/team_member_entity.dart';
import '../enums/project_status.dart';

/// Repository interface for projects
abstract class ProjectsRepository {
  /// Get all projects with optional filters
  Future<Either<Failure, List<ProjectEntity>>> getProjects({
    ProjectStatus? status,
    String? managerId,
    String? teamMemberId,
    String? searchQuery,
    int? page,
    int? limit,
  });

  /// Get a single project by ID
  Future<Either<Failure, ProjectEntity>> getProjectById(String id);

  /// Create a new project
  Future<Either<Failure, ProjectEntity>> createProject(ProjectEntity project);

  /// Update an existing project
  Future<Either<Failure, ProjectEntity>> updateProject(ProjectEntity project);

  /// Delete a project
  Future<Either<Failure, void>> deleteProject(String id);

  /// Get all team members
  Future<Either<Failure, List<TeamMemberEntity>>> getTeamMembers();

  /// Get team members for a specific project
  Future<Either<Failure, List<TeamMemberEntity>>> getProjectTeamMembers(
    String projectId,
  );

  /// Get project statistics
  Future<Either<Failure, ProjectStatistics>> getProjectStatistics();
}

/// Statistics about projects
class ProjectStatistics {
  final int total;
  final int active;
  final int completed;
  final int delayed;
  final int onHold;

  const ProjectStatistics({
    required this.total,
    required this.active,
    required this.completed,
    required this.delayed,
    required this.onHold,
  });

  factory ProjectStatistics.empty() {
    return const ProjectStatistics(
      total: 0,
      active: 0,
      completed: 0,
      delayed: 0,
      onHold: 0,
    );
  }
}

