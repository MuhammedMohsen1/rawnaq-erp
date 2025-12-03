import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../enums/task_status.dart';
import '../enums/task_type.dart';
import '../../../projects/domain/entities/team_member_entity.dart';

/// Represents a task in the system
/// - For work/general tasks: startDate and endDate include both date AND time
/// - For appointments: single-point event, endDate equals startDate
class TaskEntity extends Equatable {
  final String id;
  final String name;
  final TaskType taskType;
  final TaskStatus status;
  final String? assigneeId; // Nullable for draft tasks
  final TeamMemberEntity? assignee;
  
  /// Start date and time of the task (includes time component)
  final DateTime startDate;
  
  /// End date and time of the task (includes time component)
  /// For appointments, this equals startDate
  final DateTime endDate;
  
  final String? notes;
  final DateTime? createdAt;
  final bool isDraft; // Draft tasks have no assignee

  // Work Task fields (project-related)
  final String? projectId;
  final String? projectName;

  // Appointment fields
  final String? customerName;
  final String? customerPhone;
  final String? locationLink;

  const TaskEntity({
    required this.id,
    required this.name,
    required this.taskType,
    required this.status,
    this.assigneeId,
    this.assignee,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.createdAt,
    this.isDraft = false,
    // Work task fields
    this.projectId,
    this.projectName,
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
        isDraft,
        projectId,
        projectName,
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
    bool? isDraft,
    String? projectId,
    String? projectName,
    String? customerName,
    String? customerPhone,
    String? locationLink,
    bool clearAssignee = false,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
      assignee: clearAssignee ? null : (assignee ?? this.assignee),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      isDraft: isDraft ?? this.isDraft,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      locationLink: locationLink ?? this.locationLink,
    );
  }

  /// Check if the task is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(endDate) && status != TaskStatus.completed;
  }

  /// Get the duration in days (date-only comparison)
  int get durationDays {
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
    return endDateOnly.difference(startDateOnly).inDays + 1;
  }

  /// Get remaining days until due date
  int get remainingDays {
    final now = DateTime.now();
    final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    return endDateOnly.difference(nowDateOnly).inDays;
  }

  /// Check if this is an appointment (displayed as circle)
  bool get isAppointment => taskType == TaskType.appointment;

  /// Check if this is displayed as a bar
  bool get isBar => taskType.isBar;

  /// Check if this task is related to a project
  bool get hasProject => projectId != null && projectName != null;

  /// Get start date only (without time)
  DateTime get startDateOnly => DateTime(startDate.year, startDate.month, startDate.day);

  /// Get end date only (without time)
  DateTime get endDateOnly => DateTime(endDate.year, endDate.month, endDate.day);

  /// Get start time as TimeOfDay
  TimeOfDay get startTimeOfDay => TimeOfDay(hour: startDate.hour, minute: startDate.minute);

  /// Get end time as TimeOfDay
  TimeOfDay get endTimeOfDay => TimeOfDay(hour: endDate.hour, minute: endDate.minute);

  /// Get formatted start time
  String get formattedStartTime {
    final hour = startDate.hour % 12 == 0 ? 12 : startDate.hour % 12;
    final minute = startDate.minute.toString().padLeft(2, '0');
    final period = startDate.hour < 12 ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  /// Get formatted end time
  String get formattedEndTime {
    final hour = endDate.hour % 12 == 0 ? 12 : endDate.hour % 12;
    final minute = endDate.minute.toString().padLeft(2, '0');
    final period = endDate.hour < 12 ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  /// Alias for backward compatibility - uses startDate time
  String? get formattedTaskTime => formattedStartTime;
  
  /// Alias for appointments
  String? get formattedAppointmentTime => formattedStartTime;

  /// Helper to create new start datetime preserving time when date changes
  static DateTime combineDateAndTime(DateTime date, DateTime timeSource) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeSource.hour,
      timeSource.minute,
      timeSource.second,
    );
  }

  /// Helper to create datetime from date and TimeOfDay
  static DateTime dateWithTimeOfDay(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
