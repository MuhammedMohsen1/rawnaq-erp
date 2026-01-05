import 'package:equatable/equatable.dart';
import '../enums/project_status.dart';
import 'team_member_entity.dart';

/// Represents a project in the system
class ProjectEntity extends Equatable {
  final String id;
  final String name;
  final ProjectStatus status;
  final int progress; // 0-100
  final DateTime startDate;
  final DateTime endDate;
  final String? managerId;
  final TeamMemberEntity? manager;
  final List<String> teamMemberIds;
  final List<TeamMemberEntity>? teamMembers;
  final String? description;
  final String? clientName;
  final String? clientPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.progress,
    required this.startDate,
    required this.endDate,
    this.managerId,
    this.manager,
    this.teamMemberIds = const [],
    this.teamMembers,
    this.description,
    this.clientName,
    this.clientPhone,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        progress,
        startDate,
        endDate,
        managerId,
        manager,
        teamMemberIds,
        teamMembers,
        description,
        clientName,
        clientPhone,
        createdAt,
        updatedAt,
      ];

  /// Create a copy with updated fields
  ProjectEntity copyWith({
    String? id,
    String? name,
    ProjectStatus? status,
    int? progress,
    DateTime? startDate,
    DateTime? endDate,
    String? managerId,
    TeamMemberEntity? manager,
    List<String>? teamMemberIds,
    List<TeamMemberEntity>? teamMembers,
    String? description,
    String? clientName,
    String? clientPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      managerId: managerId ?? this.managerId,
      manager: manager ?? this.manager,
      teamMemberIds: teamMemberIds ?? this.teamMemberIds,
      teamMembers: teamMembers ?? this.teamMembers,
      description: description ?? this.description,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if the project is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(endDate) && status != ProjectStatus.completed;
  }

  /// Calculate remaining days
  int get remainingDays {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  /// Get total project duration in days
  int get durationDays {
    return endDate.difference(startDate).inDays;
  }

  /// Get elapsed days since start
  int get elapsedDays {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    return now.difference(startDate).inDays;
  }
}

