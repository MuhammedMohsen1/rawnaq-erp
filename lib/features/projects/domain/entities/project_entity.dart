import 'package:equatable/equatable.dart';
import '../enums/project_status.dart';
import 'team_member_entity.dart';

class ProjectPhoneContact extends Equatable {
  final String name;
  final String phone;

  const ProjectPhoneContact({required this.name, required this.phone});

  @override
  List<Object?> get props => [name, phone];
}

/// Represents a project in the system
class ProjectEntity extends Equatable {
  final String id;
  final String name;
  final ProjectStatus status;
  final int progress; // 0-100
  final DateTime startDate;
  final DateTime endDate;
  final bool hasEndDate;
  final double totalCost;
  final double totalPrice;
  final double totalAmountAfterDeduction;
  final double totalReceived;
  final double totalExpenses;
  final String? managerId;
  final TeamMemberEntity? manager;
  final List<String> teamMemberIds;
  final List<TeamMemberEntity>? teamMembers;
  final String? description;
  final String? clientName;
  final String? clientPhone;
  final List<ProjectPhoneContact> clientContacts;
  final String? googleMapLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastEditAt;
  final int? itemsCount;
  final bool archived;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.progress,
    required this.startDate,
    required this.endDate,
    this.hasEndDate = true,
    this.totalCost = 0,
    this.totalPrice = 0,
    this.totalAmountAfterDeduction = 0,
    this.totalReceived = 0,
    this.totalExpenses = 0,
    this.managerId,
    this.manager,
    this.teamMemberIds = const [],
    this.teamMembers,
    this.description,
    this.clientName,
    this.clientPhone,
    this.clientContacts = const [],
    this.googleMapLink,
    this.createdAt,
    this.updatedAt,
    this.lastEditAt,
    this.itemsCount,
    this.archived = false,
  });
  get deliveryInDays =>
      hasEndDate ? endDate.difference(DateTime.now()).inDays : null;
  double get projectTotalPrice => totalAmountAfterDeduction > 0
      ? totalAmountAfterDeduction
      : (totalPrice > 0 ? totalPrice : totalCost);
  get restInCash => totalCost - totalExpenses;
  @override
  List<Object?> get props => [
    id,
    name,
    status,
    progress,
    startDate,
    endDate,
    hasEndDate,
    totalCost,
    totalPrice,
    totalAmountAfterDeduction,
    totalReceived,
    totalExpenses,
    managerId,
    manager,
    teamMemberIds,
    teamMembers,
    description,
    clientName,
    clientPhone,
    clientContacts,
    googleMapLink,
    createdAt,
    updatedAt,
    lastEditAt,
    itemsCount,
    archived,
  ];

  /// Create a copy with updated fields
  ProjectEntity copyWith({
    String? id,
    String? name,
    ProjectStatus? status,
    int? progress,
    DateTime? startDate,
    DateTime? endDate,
    bool? hasEndDate,
    double? totalCost,
    double? totalPrice,
    double? totalAmountAfterDeduction,
    double? totalReceived,
    double? totalExpenses,
    String? managerId,
    TeamMemberEntity? manager,
    List<String>? teamMemberIds,
    List<TeamMemberEntity>? teamMembers,
    String? description,
    String? clientName,
    String? clientPhone,
    List<ProjectPhoneContact>? clientContacts,
    String? googleMapLink,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastEditAt,
    int? itemsCount,
    bool? archived,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      hasEndDate: hasEndDate ?? this.hasEndDate,
      totalCost: totalCost ?? this.totalCost,
      totalPrice: totalPrice ?? this.totalPrice,
      totalAmountAfterDeduction:
          totalAmountAfterDeduction ?? this.totalAmountAfterDeduction,
      totalReceived: totalReceived ?? this.totalReceived,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      managerId: managerId ?? this.managerId,
      manager: manager ?? this.manager,
      teamMemberIds: teamMemberIds ?? this.teamMemberIds,
      teamMembers: teamMembers ?? this.teamMembers,
      description: description ?? this.description,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientContacts: clientContacts ?? this.clientContacts,
      googleMapLink: googleMapLink ?? this.googleMapLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastEditAt: lastEditAt ?? this.lastEditAt,
      itemsCount: itemsCount ?? this.itemsCount,
      archived: archived ?? this.archived,
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
