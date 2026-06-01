import '../../../../core/constants/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/enums/task_type.dart';
import '../models/task_model.dart';
import '../models/team_member_model.dart';

class TasksApiDataSource {
  final ApiClient _apiClient;

  TasksApiDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<TaskModel>> getTasks({
    TaskStatus? status,
    String? assigneeId,
    String? projectId,
    TaskType? taskType,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDrafts = true,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.tasks,
      queryParameters: _query(
        status: status,
        assigneeId: assigneeId,
        projectId: projectId,
        taskType: taskType,
        startDate: startDate,
        endDate: endDate,
        includeDrafts: includeDrafts,
      ),
    );
    return _parseTasks(response.data as Map<String, dynamic>);
  }

  Future<List<TaskModel>> getMyTasks({
    TaskStatus? status,
    TaskType? taskType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.myTasks,
      queryParameters: _query(
        status: status,
        taskType: taskType,
        startDate: startDate,
        endDate: endDate,
        includeDrafts: false,
      ),
    );
    return _parseTasks(response.data as Map<String, dynamic>);
  }

  Future<List<TeamMemberModel>> getTeamMembers() async {
    final response = await _apiClient.get(ApiEndpoints.taskTeamMembers);
    final responseData = response.data as Map<String, dynamic>;
    final list = responseData['data'] as List<dynamic>;
    return list
        .map((json) => TeamMemberModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> createTask(TaskEntity task) async {
    final response = await _apiClient.post(
      ApiEndpoints.tasks,
      data: TaskModel.fromEntity(task).toJson(),
    );
    return _parseTask(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask(TaskEntity task) async {
    final response = await _apiClient.patch(
      ApiEndpoints.taskById(task.id),
      data: TaskModel.fromEntity(task).toJson(),
    );
    return _parseTask(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> scheduleTask(
    String taskId, {
    required DateTime startDate,
    DateTime? endDate,
    String? assigneeId,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.taskSchedule(taskId),
      data: {
        'startDate': startDate.toUtc().toIso8601String(),
        if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
        if (assigneeId != null) 'assigneeId': assigneeId,
      },
    );
    return _parseTask(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> assignTask(
    String taskId, {
    required String assigneeId,
    DateTime? startDate,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.taskAssign(taskId),
      data: {
        'assigneeId': assigneeId,
        if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
      },
    );
    return _parseTask(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> updateMyStatus(String taskId, TaskStatus status) async {
    final response = await _apiClient.patch(
      ApiEndpoints.taskMyStatus(taskId),
      data: {'status': status.toApiString()},
    );
    return _parseTask(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTask(String taskId) async {
    await _apiClient.delete(ApiEndpoints.taskById(taskId));
  }

  Map<String, dynamic> _query({
    TaskStatus? status,
    String? assigneeId,
    String? projectId,
    TaskType? taskType,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDrafts = false,
  }) {
    return {
      if (status != null && status != TaskStatus.delayed)
        'status': status.toApiString(),
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (projectId != null) 'projectId': projectId,
      if (taskType != null) 'type': taskType.toApiString(),
      if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
      if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
      'includeDrafts': includeDrafts.toString(),
    };
  }

  List<TaskModel> _parseTasks(Map<String, dynamic> responseData) {
    final list = responseData['data'] as List<dynamic>;
    return list
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  TaskModel _parseTask(Map<String, dynamic> responseData) {
    return TaskModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }
}
