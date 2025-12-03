import 'package:equatable/equatable.dart';

/// Represents a team member in the system
class TeamMemberEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final String? avatar;
  final String? email;
  final String? phone;

  const TeamMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    this.avatar,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [id, name, role, avatar, email, phone];

  /// Create a copy with updated fields
  TeamMemberEntity copyWith({
    String? id,
    String? name,
    String? role,
    String? avatar,
    String? email,
    String? phone,
  }) {
    return TeamMemberEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

