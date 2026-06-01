import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/enums/project_type.dart';
import 'team_member_model.dart';

class ProjectPhoneContactModel extends ProjectPhoneContact {
  const ProjectPhoneContactModel({required super.name, required super.phone});

  factory ProjectPhoneContactModel.fromJson(Map<String, dynamic> json) {
    return ProjectPhoneContactModel(
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
    );
  }

  factory ProjectPhoneContactModel.fromEntity(ProjectPhoneContact entity) {
    return ProjectPhoneContactModel(name: entity.name, phone: entity.phone);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }
}

/// Model class for Project with JSON serialization
class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.status,
    super.type,
    required super.progress,
    required super.startDate,
    required super.endDate,
    super.hasEndDate,
    super.totalCost,
    super.totalPrice,
    super.totalAmountAfterDeduction,
    super.totalReceived,
    super.totalExpenses,
    super.managerId,
    super.manager,
    super.teamMemberIds,
    super.teamMembers,
    super.description,
    super.clientName,
    super.clientPhone,
    super.clientContacts,
    super.googleMapLink,
    super.createdAt,
    super.updatedAt,
    super.lastEditAt,
    super.itemsCount,
    super.archived,
    super.installments,
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
    } else if (json['createdAt'] != null) {
      startDate = DateTime.parse(json['createdAt'] as String);
    } else {
      // If no start date, use current date as fallback
      startDate = DateTime.now();
    }

    DateTime? endDate;
    final hasEndDate = json['endDate'] != null || json['deadline'] != null;
    if (json['endDate'] != null) {
      endDate = DateTime.parse(json['endDate'] as String);
    } else if (json['deadline'] != null) {
      endDate = DateTime.parse(json['deadline'] as String);
    } else {
      // If no end date, use start date + 30 days as fallback
      endDate = startDate.add(const Duration(days: 30));
    }

    final contactsJson = json['clientContacts'];
    final clientContacts = contactsJson is List
        ? contactsJson
              .whereType<Map>()
              .map(
                (contact) => ProjectPhoneContactModel.fromJson(
                  Map<String, dynamic>.from(contact),
                ),
              )
              .where((contact) => contact.phone.trim().isNotEmpty)
              .toList()
        : <ProjectPhoneContactModel>[];
    final scheduleJson = json['installments'] ?? json['paymentSchedule'];
    final installments = scheduleJson is List
        ? scheduleJson.whereType<Map>().map((item) {
            final data = Map<String, dynamic>.from(item);
            return ProjectInstallment(
              id: (data['id'] ?? data['number'] ?? '').toString(),
              amount: _toDouble(data['amount'] ?? data['value']),
              dueDate:
                  DateTime.tryParse(
                    (data['dueDate'] ?? data['date'] ?? '').toString(),
                  ) ??
                  startDate!,
              isPaid: data['isPaid'] as bool? ?? data['paid'] as bool? ?? false,
            );
          }).toList()
        : <ProjectInstallment>[];

    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: frontendStatus,
      type: ProjectTypeExtension.fromApiString(json['type'] as String?),
      progress: (json['progress'] as int?) ?? 0,
      startDate: startDate,
      endDate: endDate,
      hasEndDate: hasEndDate,
      totalCost: _toDouble(json['totalCost']),
      totalPrice: _toDouble(json['projectValue']) > 0
          ? _toDouble(json['projectValue'])
          : _toDouble(json['totalPrice']),
      totalAmountAfterDeduction: _toDouble(json['totalAmountAfterDeduction']),
      totalReceived: _toDouble(json['totalReceived']),
      totalExpenses: _toDouble(json['totalExpenses']),
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
      clientContacts: clientContacts,
      googleMapLink: json['googleMapLink'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastEditAt: json['lastEditAt'] != null
          ? DateTime.parse(json['lastEditAt'] as String)
          : null,
      itemsCount: json['itemsCount'] as int?,
      archived: json['archived'] as bool? ?? json['deletedAt'] != null,
      installments: installments,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toApiString(),
      'type': type.apiValue,
      'progress': progress,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'hasEndDate': hasEndDate,
      'totalCost': totalCost,
      'totalPrice': totalPrice,
      'totalAmountAfterDeduction': totalAmountAfterDeduction,
      'totalReceived': totalReceived,
      'totalExpenses': totalExpenses,
      'managerId': managerId,
      'manager': manager != null
          ? TeamMemberModel.fromEntity(manager!).toJson()
          : null,
      'teamMemberIds': teamMemberIds,
      'teamMembers': teamMembers
          ?.map((e) => TeamMemberModel.fromEntity(e).toJson())
          .toList(),
      'description': description,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientContacts': clientContacts
          .map((e) => ProjectPhoneContactModel.fromEntity(e).toJson())
          .toList(),
      'googleMapLink': googleMapLink,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastEditAt': lastEditAt?.toIso8601String(),
      'archived': archived,
      'installments': installments
          .map(
            (item) => {
              'id': item.id,
              'amount': item.amount,
              'dueDate': item.dueDate.toIso8601String(),
              'isPaid': item.isPaid,
            },
          )
          .toList(),
    };
  }

  /// Create from entity
  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      status: entity.status,
      type: entity.type,
      progress: entity.progress,
      startDate: entity.startDate,
      endDate: entity.endDate,
      hasEndDate: entity.hasEndDate,
      totalCost: entity.totalCost,
      totalPrice: entity.totalPrice,
      totalAmountAfterDeduction: entity.totalAmountAfterDeduction,
      totalReceived: entity.totalReceived,
      totalExpenses: entity.totalExpenses,
      managerId: entity.managerId,
      manager: entity.manager,
      teamMemberIds: entity.teamMemberIds,
      teamMembers: entity.teamMembers,
      description: entity.description,
      clientName: entity.clientName,
      clientPhone: entity.clientPhone,
      clientContacts: entity.clientContacts,
      googleMapLink: entity.googleMapLink,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastEditAt: entity.lastEditAt,
      itemsCount: entity.itemsCount,
      archived: entity.archived,
      installments: entity.installments,
    );
  }

  /// Convert to entity
  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      name: name,
      status: status,
      type: type,
      progress: progress,
      startDate: startDate,
      endDate: endDate,
      hasEndDate: hasEndDate,
      totalCost: totalCost,
      totalPrice: totalPrice,
      totalAmountAfterDeduction: totalAmountAfterDeduction,
      totalReceived: totalReceived,
      totalExpenses: totalExpenses,
      managerId: managerId,
      manager: manager,
      teamMemberIds: teamMemberIds,
      teamMembers: teamMembers,
      description: description,
      clientName: clientName,
      clientPhone: clientPhone,
      clientContacts: clientContacts,
      googleMapLink: googleMapLink,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastEditAt: lastEditAt,
      itemsCount: itemsCount,
      archived: archived,
      installments: installments,
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
