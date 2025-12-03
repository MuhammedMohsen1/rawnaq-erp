import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/mock_projects_datasource.dart';

/// Implementation of ProjectsRepository using mock data
class ProjectsRepositoryImpl implements ProjectsRepository {
  final MockProjectsDataSource _dataSource;

  ProjectsRepositoryImpl({MockProjectsDataSource? dataSource})
      : _dataSource = dataSource ?? MockProjectsDataSource();

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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final projects = _dataSource.getProjects(
        status: status,
        managerId: managerId,
        teamMemberId: teamMemberId,
        searchQuery: searchQuery,
      );

      // Handle pagination
      if (page != null && limit != null) {
        final start = (page - 1) * limit;
        final end = start + limit;
        if (start >= projects.length) {
          return const Right([]);
        }
        return Right(projects.sublist(
          start,
          end > projects.length ? projects.length : end,
        ));
      }

      return Right(projects);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> getProjectById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final project = _dataSource.getProjectById(id);
      if (project == null) {
        return const Left(ServerFailure(message: 'Project not found'));
      }
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
      await Future.delayed(const Duration(milliseconds: 500));

      final newProject = _dataSource.createProject(project);
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
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedProject = _dataSource.updateProject(project);
      if (updatedProject == null) {
        return const Left(ServerFailure(message: 'Project not found'));
      }
      return Right(updatedProject);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final success = _dataSource.deleteProject(id);
      if (!success) {
        return const Left(ServerFailure(message: 'Project not found'));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TeamMemberEntity>>> getTeamMembers() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final members = _dataSource.getTeamMembers();
      return Right(members);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TeamMemberEntity>>> getProjectTeamMembers(
    String projectId,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final project = _dataSource.getProjectById(projectId);
      if (project == null) {
        return const Left(ServerFailure(message: 'Project not found'));
      }
      return Right(project.teamMembers ?? []);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectStatistics>> getProjectStatistics() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final stats = _dataSource.getProjectStatistics();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

