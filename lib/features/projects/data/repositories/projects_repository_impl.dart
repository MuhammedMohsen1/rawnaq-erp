import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_api_datasource.dart';
import '../models/project_model.dart';

/// Implementation of ProjectsRepository using API
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsApiDataSource _dataSource;

  ProjectsRepositoryImpl({ProjectsApiDataSource? dataSource})
    : _dataSource = dataSource ?? ProjectsApiDataSource();

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects({
    ProjectStatus? status,
    String? managerId,
    String? teamMemberId,
    String? searchQuery,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _dataSource.getProjects(
        status: status,
        clientName: searchQuery, // Use clientName for search
        page: page ?? 1,
        limit: limit ?? 10,
      );

      // Parse the response - backend returns { projects: [], total: number, page: number, limit: number }
      final projectsList = response['projects'] as List<dynamic>;
      final projects = projectsList
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(projects);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> getProjectById(String id) async {
    try {
      final response = await _dataSource.getProjectById(id);
      final project = ProjectModel.fromJson(response);
      return Right(project);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> createProject(
    ProjectEntity project,
  ) async {
    try {
      // This method signature doesn't include all required fields
      // The CreateProject event should pass a map with all data
      // For now, return an error indicating the new signature is needed
      return const Left(
        ServerFailure(message: 'Please use createProjectWithData instead'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Create project with full data including type and department
  Future<Either<Failure, ProjectEntity>> createProjectWithData({
    required String name,
    String? description,
    required String type, // 'DESIGN' or 'EXECUTION'
    required String primaryDepartmentId,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? deadline,
    int progress = 0,
  }) async {
    try {
      // Convert entity to API format
      final projectData = <String, dynamic>{
        'name': name,
        'type': type,
        'primaryDepartmentId': primaryDepartmentId,
        'progress': progress,
      };

      if (description != null && description.isNotEmpty) {
        projectData['description'] = description;
      }
      if (clientName != null && clientName.isNotEmpty) {
        projectData['clientName'] = clientName;
      }
      if (clientPhone != null && clientPhone.isNotEmpty) {
        projectData['clientPhone'] = clientPhone;
      }
      if (clientEmail != null && clientEmail.isNotEmpty) {
        projectData['clientEmail'] = clientEmail;
      }
      if (startDate != null) {
        projectData['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        projectData['endDate'] = endDate.toIso8601String();
      }
      if (deadline != null) {
        projectData['deadline'] = deadline.toIso8601String();
      }

      final response = await _dataSource.createProject(projectData);
      final newProject = ProjectModel.fromJson(response);
      return Right(newProject);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> updateProject(
    ProjectEntity project,
  ) async {
    try {
      // Convert entity to API format
      final projectData = <String, dynamic>{
        'name': project.name,
        'endDate': project.endDate.toIso8601String(),
      };

      if (project.description != null && project.description!.isNotEmpty) {
        projectData['description'] = project.description;
      }

      // Always include clientName and clientPhone (send null if empty to clear them)
      projectData['clientName'] = project.clientName?.isNotEmpty == true
          ? project.clientName
          : null;
      projectData['clientPhone'] = project.clientPhone?.isNotEmpty == true
          ? project.clientPhone
          : null;

      final response = await _dataSource.updateProject(project.id, projectData);
      final updatedProject = ProjectModel.fromJson(response);
      return Right(updatedProject);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String id) async {
    try {
      await _dataSource.deleteProject(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TeamMemberEntity>>> getTeamMembers() async {
    try {
      // TODO: Implement when team members endpoint is available
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TeamMemberEntity>>> getProjectTeamMembers(
    String projectId,
  ) async {
    try {
      // TODO: Implement when project team members endpoint is available
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectStatistics>> getProjectStatistics() async {
    try {
      // Get projects with a reasonable limit to calculate statistics
      // Reduced from 1000 to avoid rate limiting (429 errors)
      final allProjectsResponse = await _dataSource.getProjects(
        page: 1,
        limit: 100,
      );

      final projectsList = allProjectsResponse['projects'] as List<dynamic>;
      final projects = projectsList
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Get total count from pagination metadata
      final totalCount =
          (allProjectsResponse['total'] as int?) ?? projects.length;

      // Calculate statistics from the fetched projects
      // Note: These counts are based on the first 100 projects only
      // Calculate stats based on new status values
      final draft = projects
          .where((p) => p.status == ProjectStatus.draft)
          .length;
      final underPricing = projects
          .where((p) => p.status == ProjectStatus.underPricing)
          .length;
      final profitPending = projects
          .where((p) => p.status == ProjectStatus.pendingSignature)
          .length;
      final pendingApproval = projects
          .where((p) => p.status == ProjectStatus.pendingApproval)
          .length;
      final execution = projects
          .where((p) => p.status == ProjectStatus.execution)
          .length;
      final completed = projects
          .where((p) => p.status == ProjectStatus.completed)
          .length;

      // Map to old stats format for compatibility (if needed)
      final active = execution; // Execution is the active state
      final delayed = 0; // No longer tracked separately
      final onHold = draft + underPricing + profitPending + pendingApproval;

      return Right(
        ProjectStatistics(
          total: totalCount,
          active: active,
          completed: completed,
          delayed: delayed,
          onHold: onHold,
        ),
      );
    } catch (e) {
      // If we get a rate limit error (429), return a default statistics object
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('429') ||
          errorString.contains('rate limit') ||
          errorString.contains('too many requests')) {
        return Right(
          ProjectStatistics(
            total: 0,
            active: 0,
            completed: 0,
            delayed: 0,
            onHold: 0,
          ),
        );
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
