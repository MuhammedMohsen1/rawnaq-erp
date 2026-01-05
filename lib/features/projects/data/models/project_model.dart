import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';
import 'team_member_model.dart';

/// Model class for Project with JSON serialization
class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.status,
    required super.progress,
    required super.startDate,
    required super.endDate,
    super.managerId,
    super.manager,
    super.teamMemberIds,
    super.teamMembers,
    super.description,
    super.clientName,
    super.clientPhone,
    super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON (backend format)
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // Parse backend status directly using the enum's fromApiString method
    final backendStatus = json['status'] as String? ?? 'DRAFT';
    final frontendStatus = ProjectStatusExtension.fromApiString(backendStatus);

    // Handle nullable dates from backend
    DateTime? startDate;
    if (json['startDate'] != null) {
      startDate = DateTime.parse(json['startDate'] as String);
    } else {
      // If no start date, use current date as fallback
      startDate = DateTime.now();
    }

    DateTime? endDate;
    if (json['endDate'] != null) {
      endDate = DateTime.parse(json['endDate'] as String);
    } else if (json['deadline'] != null) {
      endDate = DateTime.parse(json['deadline'] as String);
    } else {
      // If no end date, use start date + 30 days as fallback
      endDate = startDate.add(const Duration(days: 30));
    }

    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: frontendStatus,
      progress: (json['progress'] as int?) ?? 0,
      startDate: startDate,
      endDate: endDate,
      managerId:
          json['createdById']
              as String?, // Use createdById as managerId for now
      manager: null, // Backend doesn't return manager in project response
      teamMemberIds:
          const [], // Backend doesn't return team members in project response
      teamMembers: null,
      description: json['description'] as String?,
      clientName: json['clientName'] as String?,
      clientPhone: json['clientPhone'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toApiString(),
      'progress': progress,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'managerId': managerId,
      'manager': manager != null
          ? TeamMemberModel.fromEntity(manager!).toJson()
          : null,
      'teamMemberIds': teamMemberIds,
      'teamMembers': teamMembers
          ?.map((e) => TeamMemberModel.fromEntity(e).toJson())
          .toList(),
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from entity
  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      status: entity.status,
      progress: entity.progress,
      startDate: entity.startDate,
      endDate: entity.endDate,
      managerId: entity.managerId,
      manager: entity.manager,
      teamMemberIds: entity.teamMemberIds,
      teamMembers: entity.teamMembers,
      description: entity.description,
      clientName: entity.clientName,
      clientPhone: entity.clientPhone,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to entity
  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      name: name,
      status: status,
      progress: progress,
      startDate: startDate,
      endDate: endDate,
      managerId: managerId,
      manager: manager,
      teamMemberIds: teamMemberIds,
      teamMembers: teamMembers,
      description: description,
      clientName: clientName,
      clientPhone: clientPhone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
