import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../enums/task_status.dart';
import '../enums/task_type.dart';
import '../../../projects/domain/entities/team_member_entity.dart';

/// Represents a task in the system
class TaskEntity extends Equatable {
  final String id;
  final String name;
  final TaskType taskType;
  final TaskStatus status;
  final String assigneeId;
  final TeamMemberEntity? assignee;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  final DateTime? createdAt;

  // Work Task fields (project-related)
  final String? projectId;
  final String? projectName;

  // Time field (for work tasks and appointments)
  final TimeOfDay? taskTime;

  // Appointment fields
  final String? customerName;
  final String? customerPhone;
  final String? locationLink;

  const TaskEntity({
    required this.id,
    required this.name,
    required this.taskType,
    required this.status,
    required this.assigneeId,
    this.assignee,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.createdAt,
    // Work task fields
    this.projectId,
    this.projectName,
    // Time field
    this.taskTime,
    // Appointment fields
    this.customerName,
    this.customerPhone,
    this.locationLink,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        taskType,
        status,
        assigneeId,
        assignee,
        startDate,
        endDate,
        notes,
        createdAt,
        projectId,
        projectName,
        taskTime,
        customerName,
        customerPhone,
        locationLink,
      ];

  /// Create a copy with updated fields
  TaskEntity copyWith({
    String? id,
    String? name,
    TaskType? taskType,
    TaskStatus? status,
    String? assigneeId,
    TeamMemberEntity? assignee,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    DateTime? createdAt,
    String? projectId,
    String? projectName,
    TimeOfDay? taskTime,
    String? customerName,
    String? customerPhone,
    String? locationLink,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      assigneeId: assigneeId ?? this.assigneeId,
      assignee: assignee ?? this.assignee,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      taskTime: taskTime ?? this.taskTime,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      locationLink: locationLink ?? this.locationLink,
    );
  }

  /// Check if the task is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(endDate) && status != TaskStatus.completed;
  }

  /// Get the duration in days
  int get durationDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Get remaining days until due date
  int get remainingDays {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  /// Check if this is an appointment (displayed as circle)
  bool get isAppointment => taskType == TaskType.appointment;

  /// Check if this is displayed as a bar
  bool get isBar => taskType.isBar;

  /// Check if this task is related to a project
  bool get hasProject => projectId != null && projectName != null;

  /// Get formatted task time
  String? get formattedTaskTime {
    if (taskTime == null) return null;
    final hour = taskTime!.hourOfPeriod == 0 ? 12 : taskTime!.hourOfPeriod;
    final minute = taskTime!.minute.toString().padLeft(2, '0');
    final period = taskTime!.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  /// Alias for backward compatibility
  TimeOfDay? get appointmentTime => taskTime;
  String? get formattedAppointmentTime => formattedTaskTime;
}
