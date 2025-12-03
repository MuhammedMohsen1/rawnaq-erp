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
    super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: ProjectStatusExtension.fromApiString(json['status'] as String),
      progress: json['progress'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      managerId: json['managerId'] as String?,
      manager: json['manager'] != null
          ? TeamMemberModel.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
      teamMemberIds: (json['teamMemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      teamMembers: (json['teamMembers'] as List<dynamic>?)
          ?.map((e) => TeamMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
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
      'manager':
          manager != null ? TeamMemberModel.fromEntity(manager!).toJson() : null,
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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

