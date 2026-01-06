import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final String role;
  final List<String>? adminSubRoles; // Admin can have sub-roles
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? openingTime;
  final String? closingTime;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    required this.role,
    this.adminSubRoles,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
    this.openingTime,
    this.closingTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Map accountStatus enum to isActive boolean
    // Backend returns accountStatus: "ACTIVE" | "SUSPENDED" | "BANNED" | "PENDING"
    // Flutter uses isActive: true if accountStatus == "ACTIVE", false otherwise
    final accountStatus = json['accountStatus'] as String?;
    final isActive = accountStatus == 'ACTIVE';

    // Normalize role to lowercase (backend returns uppercase like "SITE_ENGINEER")
    final rawRole = json['role'] as String;
    final normalizedRole = rawRole.toLowerCase();

    // Normalize adminSubRoles to lowercase if they exist
    final List<String>? normalizedAdminSubRoles = json['adminSubRoles'] != null
        ? (json['adminSubRoles'] as List)
            .map((subRole) => (subRole as String).toLowerCase())
            .toList()
        : null;

    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: normalizedRole,
      adminSubRoles: normalizedAdminSubRoles,
      isActive: json['isActive'] as bool? ?? isActive,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      openingTime: json['restaurant']?['openingTime'] as String?,
      closingTime: json['restaurant']?['closingTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'adminSubRoles': adminSubRoles,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),

      if (openingTime != null) 'restaurant': {'openingTime': openingTime},
      if (closingTime != null) 'restaurant': {'closingTime': closingTime},
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatar,
    String? role,
    List<String>? adminSubRoles,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    String? openingTime,
    String? closingTime,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      adminSubRoles: adminSubRoles ?? this.adminSubRoles,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
    );
  }

  // Role checking methods
  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isSeniorEngineer => role == 'senior_engineer';
  bool get isJuniorEngineer => role == 'junior_engineer';
  bool get isSiteEngineer => role == 'site_engineer';

  // Admin sub-role checking
  bool hasAdminSubRole(String subRole) {
    if (!isAdmin) return false;
    return adminSubRoles?.contains(subRole) ?? false;
  }

  bool get isSystemAdmin => isAdmin && (adminSubRoles?.contains('system_admin') ?? true);
  bool get isProjectAdmin => isAdmin && (adminSubRoles?.contains('project_admin') ?? true);
  bool get isFinancialAdmin => isAdmin && (adminSubRoles?.contains('financial_admin') ?? true);
  bool get isTechnicalAdmin => isAdmin && (adminSubRoles?.contains('technical_admin') ?? true);

  // Check if user can access all projects
  bool get canAccessAllProjects {
    return isAdmin || isManager || isSeniorEngineer;
  }

  // Check if user can manage projects
  bool get canManageProjects {
    return isAdmin || isManager;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    avatar,
    role,
    adminSubRoles,
    isActive,
    createdAt,
    lastLoginAt,
    openingTime,
    closingTime,
  ];
}
