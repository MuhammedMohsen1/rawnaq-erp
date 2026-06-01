import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/enums/task_type.dart';
import 'team_member_model.dart';

class TaskModel extends TaskEntity {
  final bool wasAdjusted;

  const TaskModel({
    required super.id,
    required super.name,
    required super.taskType,
    required super.status,
    super.assigneeId,
    super.assignee,
    required super.startDate,
    required super.endDate,
    super.notes,
    super.createdAt,
    super.isDraft,
    super.projectId,
    super.projectName,
    super.customerName,
    super.customerPhone,
    super.locationLink,
    this.wasAdjusted = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final assigneeJson = json['assignee'] as Map<String, dynamic>?;
    return TaskModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      taskType: TaskTypeExtension.fromApiString(json['type'] as String? ?? ''),
      status: TaskStatusExtension.fromApiString(
        json['displayStatus'] as String? ?? json['status'] as String? ?? '',
      ),
      assigneeId: json['assigneeId'] as String?,
      assignee: assigneeJson == null
          ? null
          : TeamMemberModel.fromJson(assigneeJson),
      startDate: DateTime.parse(json['startDate'] as String).toLocal(),
      endDate: DateTime.parse(json['endDate'] as String).toLocal(),
      notes: (json['notes'] ?? json['description']) as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String).toLocal(),
      isDraft: json['isDraft'] as bool? ?? false,
      projectId: json['projectId'] as String?,
      projectName: json['projectName'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      locationLink: json['locationLink'] as String?,
      wasAdjusted: json['wasAdjusted'] as bool? ?? false,
    );
  }

  factory TaskModel.fromEntity(TaskEntity task) {
    return TaskModel(
      id: task.id,
      name: task.name,
      taskType: task.taskType,
      status: task.status == TaskStatus.delayed
          ? TaskStatus.waiting
          : task.status,
      assigneeId: task.assigneeId,
      assignee: task.assignee,
      startDate: task.startDate,
      endDate: task.endDate,
      notes: task.notes,
      createdAt: task.createdAt,
      isDraft: task.isDraft,
      projectId: task.projectId,
      projectName: task.projectName,
      customerName: task.customerName,
      customerPhone: task.customerPhone,
      locationLink: task.locationLink,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': taskType.toApiString(),
      'status': status.toApiString(),
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      if (projectId != null) 'projectId': projectId,
      if (assigneeId != null && !isDraft) 'assigneeId': assigneeId,
      if (notes != null) 'notes': notes,
      if (customerName != null) 'customerName': customerName,
      if (customerPhone != null) 'customerPhone': customerPhone,
      if (locationLink != null) 'locationLink': locationLink,
      'isDraft': isDraft,
    };
  }
}
