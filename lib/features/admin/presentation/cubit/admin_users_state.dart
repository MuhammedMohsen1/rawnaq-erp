import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

enum AdminUsersStatus { initial, loading, loaded, saving, error }

class AdminUsersState extends Equatable {
  final AdminUsersStatus status;
  final List<User> users;
  final String searchQuery;
  final String roleFilter;
  final String statusFilter;
  final String? errorMessage;
  final String? successMessage;

  const AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.users = const [],
    this.searchQuery = '',
    this.roleFilter = 'all',
    this.statusFilter = 'all',
    this.errorMessage,
    this.successMessage,
  });

  List<User> get filteredUsers {
    final query = searchQuery.trim().toLowerCase();

    return users.where((user) {
      final matchesSearch =
          query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.phone?.toLowerCase().contains(query) ?? false);
      final matchesRole = roleFilter == 'all' || user.role == roleFilter;
      final matchesStatus =
          statusFilter == 'all' ||
          (statusFilter == 'ACTIVE' && user.isActive) ||
          (statusFilter == 'SUSPENDED' && !user.isActive);

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  bool get isLoading => status == AdminUsersStatus.loading;
  bool get isSaving => status == AdminUsersStatus.saving;

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<User>? users,
    String? searchQuery,
    String? roleFilter,
    String? statusFilter,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    users,
    searchQuery,
    roleFilter,
    statusFilter,
    errorMessage,
    successMessage,
  ];
}
