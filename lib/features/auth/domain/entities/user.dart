import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final String role;
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
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
    this.openingTime,
    this.closingTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? true,
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
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    avatar,
    role,
    isActive,
    createdAt,
    lastLoginAt,
    openingTime,
    closingTime,
  ];
}
