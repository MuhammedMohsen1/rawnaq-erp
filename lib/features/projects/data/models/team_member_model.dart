import '../../domain/entities/team_member_entity.dart';

/// Model class for TeamMember with JSON serialization
class TeamMemberModel extends TeamMemberEntity {
  const TeamMemberModel({
    required super.id,
    required super.name,
    required super.role,
    super.avatar,
    super.email,
    super.phone,
  });

  /// Create from JSON
  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatar': avatar,
      'email': email,
      'phone': phone,
    };
  }

  /// Create from entity
  factory TeamMemberModel.fromEntity(TeamMemberEntity entity) {
    return TeamMemberModel(
      id: entity.id,
      name: entity.name,
      role: entity.role,
      avatar: entity.avatar,
      email: entity.email,
      phone: entity.phone,
    );
  }

  /// Convert to entity
  TeamMemberEntity toEntity() {
    return TeamMemberEntity(
      id: id,
      name: name,
      role: role,
      avatar: avatar,
      email: email,
      phone: phone,
    );
  }
}

