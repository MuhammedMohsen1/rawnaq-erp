import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/error/failures.dart';
import '../../../execution/data/datasources/execution_api_datasource.dart';
import '../../../pricing/data/datasources/pricing_api_datasource.dart';
import '../../domain/entities/project_attachment_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/enums/project_type.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_api_datasource.dart';
import '../models/project_attachment_model.dart';
import '../models/project_model.dart';

/// Implementation of ProjectsRepository using API
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsApiDataSource _dataSource;
  final ExecutionApiDataSource _executionDataSource;
  final PricingApiDataSource _pricingDataSource;

  ProjectsRepositoryImpl({
    ProjectsApiDataSource? dataSource,
    ExecutionApiDataSource? executionDataSource,
    PricingApiDataSource? pricingDataSource,
  }) : _dataSource = dataSource ?? ProjectsApiDataSource(),
       _executionDataSource = executionDataSource ?? ExecutionApiDataSource(),
       _pricingDataSource = pricingDataSource ?? PricingApiDataSource();

  @override
  Future<Either<Failure, PaginatedProjectsResult>> getProjects({
    ProjectStatus? status,
    String? type,
    String? managerId,
    String? teamMemberId,
    String? searchQuery,
    bool archived = false,
    bool assignedToMe = false,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _dataSource.getProjects(
        status: status,
        type: type,
        search: searchQuery,
        archived: archived,
        assignedToMe: assignedToMe,
        page: page ?? 1,
        limit: limit ?? 10,
      );

      // Parse the response - backend returns { projects: [], total: number, page: number, limit: number }
      final projectsList = response['projects'] as List<dynamic>;
      final projects = projectsList
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
      final enrichedProjects = await _enrichProjectFinancials(projects);
      final total = (response['total'] as num?)?.toInt() ?? projects.length;
      final currentPage = (response['page'] as num?)?.toInt() ?? (page ?? 1);
      final currentLimit =
          (response['limit'] as num?)?.toInt() ?? (limit ?? 10);

      return Right(
        PaginatedProjectsResult(
          projects: enrichedProjects,
          total: total,
          page: currentPage,
          limit: currentLimit,
        ),
      );
    } catch (e) {
      return Left(_attachmentFailure(e));
    }
  }

  Future<List<ProjectEntity>> _enrichProjectFinancials(
    List<ProjectEntity> projects,
  ) async {
    return Future.wait(projects.map(_enrichProjectFinancial));
  }

  Future<ProjectEntity> _enrichProjectFinancial(ProjectEntity project) async {
    if (project.status == ProjectStatus.execution ||
        project.status == ProjectStatus.completed) {
      final executionProject = await _tryEnrichFromExecution(project);
      if (executionProject.projectTotalPrice > 0 ||
          executionProject.totalExpenses > 0) {
        return executionProject;
      }
    }

    if (project.projectTotalPrice > 0) return project;

    return _tryEnrichFromPricing(project);
  }

  Future<ProjectEntity> _tryEnrichFromExecution(ProjectEntity project) async {
    try {
      final dashboard = await _executionDataSource.getExecutionDashboard(
        project.id,
      );
      final projectTotal = dashboard.totalAmountAfterDeduction > 0
          ? dashboard.totalAmountAfterDeduction
          : dashboard.totalPrice;

      if (projectTotal <= 0 && dashboard.totalExpenses <= 0) return project;

      return project.copyWith(
        totalCost: project.totalCost > 0
            ? project.totalCost
            : dashboard.totalBudget,
        totalPrice: dashboard.totalPrice,
        totalAmountAfterDeduction: dashboard.totalAmountAfterDeduction,
        totalReceived: dashboard.totalReceived,
        totalExpenses: dashboard.totalExpenses,
      );
    } catch (_) {
      return project;
    }
  }

  Future<ProjectEntity> _tryEnrichFromPricing(ProjectEntity project) async {
    try {
      final versions = await _pricingDataSource.getPricingVersions(project.id);
      if (versions.isEmpty) return project;

      final latest = versions.reduce(
        (current, next) => next.version > current.version ? next : current,
      );
      final totalAmount = latest.totalAmountAfterDeduction > 0
          ? latest.totalAmountAfterDeduction
          : latest.totalPrice;

      if (totalAmount <= 0) return project;

      return project.copyWith(
        totalCost: latest.totalCost > 0 ? latest.totalCost : project.totalCost,
        totalPrice: latest.totalPrice,
        totalAmountAfterDeduction: latest.totalAmountAfterDeduction,
      );
    } catch (_) {
      return project;
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> updateProjectStatus(
    String id,
    ProjectStatus status, {
    String? notes,
  }) async {
    try {
      final response = await _dataSource.updateProjectStatus(
        id,
        status.toApiString(),
        notes,
      );
      final updatedProject = ProjectModel.fromJson(response);
      return Right(updatedProject);
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
      return Left(_attachmentFailure(e));
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
      return Left(_attachmentFailure(e));
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
    List<ProjectPhoneContact> clientContacts = const [],
    String? clientEmail,
    String? googleMapLink,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? deadline,
    int progress = 0,
    double projectValue = 0,
    List<ProjectInstallment> installments = const [],
  }) async {
    try {
      // Convert entity to API format
      final projectData = <String, dynamic>{
        'name': name,
        'type': type,
        'primaryDepartmentId': primaryDepartmentId,
        'progress': progress,
        if (projectValue > 0) 'projectValue': projectValue,
        if (installments.isNotEmpty) 'installmentCount': installments.length,
        if (installments.isNotEmpty)
          'paymentSchedule': installments
              .map(
                (item) => {
                  'id': item.id,
                  'amount': item.amount,
                  'dueDate': item.dueDate.toIso8601String(),
                  'isPaid': item.isPaid,
                  'notes': item.notes,
                },
              )
              .toList(),
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
      if (clientContacts.isNotEmpty) {
        projectData['clientContacts'] = clientContacts
            .map((contact) => {'name': contact.name, 'phone': contact.phone})
            .toList();
      }
      if (clientEmail != null && clientEmail.isNotEmpty) {
        projectData['clientEmail'] = clientEmail;
      }
      if (googleMapLink != null && googleMapLink.isNotEmpty) {
        projectData['googleMapLink'] = googleMapLink;
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
        'startDate': project.startDate.toIso8601String(),
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
      if (project.clientContacts.isNotEmpty) {
        projectData['clientContacts'] = project.clientContacts
            .map((contact) => {'name': contact.name, 'phone': contact.phone})
            .toList();
      }
      if (project.googleMapLink?.isNotEmpty == true) {
        projectData['googleMapLink'] = project.googleMapLink;
      }
      if (project.type == ProjectType.design) {
        projectData['projectValue'] = project.totalPrice;
        projectData['installmentCount'] = project.installments.length;
        projectData['paymentSchedule'] = project.installments
            .map(
              (installment) => {
                'id': installment.id,
                'amount': installment.amount,
                'dueDate': installment.dueDate.toIso8601String(),
                'isPaid': installment.isPaid,
                'notes': installment.notes,
              },
            )
            .toList();
      }

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
  Future<Either<Failure, ProjectEntity>> restoreProject(String id) async {
    try {
      final response = await _dataSource.restoreProject(id);
      final restoredProject = ProjectModel.fromJson(response);
      return Right(restoredProject);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProjectAttachmentEntity>>> getProjectAttachments(
    String projectId,
  ) async {
    try {
      final response = await _dataSource.getProjectAttachments(projectId);
      final attachments = response
          .map(
            (json) =>
                ProjectAttachmentModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return Right(attachments);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProjectAttachmentEntity>>>
  uploadProjectAttachments(
    String projectId,
    List<String> filePaths, {
    List<MapEntry<String, List<int>>>? fileBytes,
  }) async {
    try {
      final response = await _dataSource.uploadProjectAttachments(
        projectId,
        filePaths,
        fileBytes: fileBytes,
      );
      final attachments = response
          .map(
            (json) =>
                ProjectAttachmentModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return Right(attachments);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProjectAttachment(
    String projectId,
    String attachmentId,
  ) async {
    try {
      await _dataSource.deleteProjectAttachment(projectId, attachmentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectAttachmentEntity>> replaceProjectAttachment(
    String projectId,
    String attachmentId, {
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final response = await _dataSource.replaceProjectAttachment(
        projectId,
        attachmentId,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      return Right(ProjectAttachmentModel.fromJson(response));
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
      final execution = projects
          .where((p) => p.status == ProjectStatus.execution)
          .length;
      final completed = projects
          .where((p) => p.status == ProjectStatus.completed)
          .length;

      // Map to old stats format for compatibility (if needed)
      final active = execution; // Execution is the active state
      final delayed = 0; // No longer tracked separately
      final onHold = draft + underPricing + profitPending;

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

Failure _attachmentFailure(Object error) {
  if (error is app_exceptions.NotFoundException) {
    final message = error.message.contains('/attachments')
        ? 'خدمة مرفقات المشروع غير متاحة. تأكد من تشغيل آخر نسخة من الخادم وتطبيق migration.'
        : error.message;
    return NotFoundFailure(message: message, code: error.code);
  }
  if (error is app_exceptions.ValidationException) {
    return ValidationFailure(message: error.message, code: error.code);
  }
  if (error is app_exceptions.UnauthorizedException) {
    return UnauthorizedFailure(message: error.message, code: error.code);
  }
  if (error is app_exceptions.TimeoutException) {
    return TimeoutFailure(message: error.message, code: error.code);
  }
  if (error is app_exceptions.ServerException) {
    return ServerFailure(message: error.message, code: error.code);
  }
  return ServerFailure(message: error.toString());
}
