import '../../../../core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';
import '../../domain/enums/project_status.dart';

/// API data source for projects
class ProjectsApiDataSource {
  final ApiClient _apiClient;

  ProjectsApiDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all projects with optional filters
  Future<Map<String, dynamic>> getProjects({
    ProjectStatus? status,
    String? type,
    String? departmentId,
    String? clientName,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (status != null) {
      // Map frontend status to backend status
      queryParams['status'] = _mapStatusToBackend(status);
    }
    if (type != null) queryParams['type'] = type;
    if (departmentId != null) queryParams['departmentId'] = departmentId;
    if (clientName != null) queryParams['clientName'] = clientName;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _apiClient.get(
      ApiEndpoints.projects,
      queryParameters: queryParams,
    );

    // Extract data from standard response format
    final responseData = response.data as Map<String, dynamic>;
    return responseData['data'] as Map<String, dynamic>;
  }

  /// Get a single project by ID
  Future<Map<String, dynamic>> getProjectById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.projectById(id));
    
    // Extract data from standard response format
    final responseData = response.data as Map<String, dynamic>;
    return responseData['data'] as Map<String, dynamic>;
  }

  /// Create a new project
  Future<Map<String, dynamic>> createProject(Map<String, dynamic> projectData) async {
    final response = await _apiClient.post(
      ApiEndpoints.projects,
      data: projectData,
    );
    
    // Extract data from standard response format
    final responseData = response.data as Map<String, dynamic>;
    return responseData['data'] as Map<String, dynamic>;
  }

  /// Update an existing project
  Future<Map<String, dynamic>> updateProject(
    String id,
    Map<String, dynamic> projectData,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.projectById(id),
      data: projectData,
    );
    
    // Extract data from standard response format
    final responseData = response.data as Map<String, dynamic>;
    return responseData['data'] as Map<String, dynamic>;
  }

  /// Update project status
  Future<Map<String, dynamic>> updateProjectStatus(
    String id,
    String status,
    String? notes,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.updateProjectStatus(id),
      data: {
        'status': status,
        if (notes != null) 'notes': notes,
      },
    );
    
    // Extract data from standard response format
    final responseData = response.data as Map<String, dynamic>;
    return responseData['data'] as Map<String, dynamic>;
  }

  /// Delete a project
  Future<void> deleteProject(String id) async {
    await _apiClient.delete(ApiEndpoints.projectById(id));
  }

  /// Map frontend ProjectStatus to backend ProjectStatus enum value
  String _mapStatusToBackend(ProjectStatus status) {
    // Use the extension method to convert to API string format
    return status.toApiString();
  }
}

