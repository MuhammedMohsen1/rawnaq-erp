import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

sealed class AdminUsersState extends Equatable {
  final List<User> users;
  final String searchQuery;
  final String roleFilter;
  final String statusFilter;
  final String? errorMessage;
  final String? successMessage;

  const AdminUsersState({
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

  bool get isLoading => false;
  bool get isSaving => false;

  @override
  List<Object?> get props => [
    users,
    searchQuery,
    roleFilter,
    statusFilter,
    errorMessage,
    successMessage,
  ];
}

final class AdminUsersInitial extends AdminUsersState {
  const AdminUsersInitial();
}

final class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading({
    super.users,
    super.searchQuery,
    super.roleFilter,
    super.statusFilter,
  });

  @override
  bool get isLoading => true;
}

final class AdminUsersLoaded extends AdminUsersState {
  const AdminUsersLoaded({
    super.users,
    super.searchQuery,
    super.roleFilter,
    super.statusFilter,
    super.errorMessage,
    super.successMessage,
  });
}

final class AdminUsersSaving extends AdminUsersState {
  const AdminUsersSaving({
    super.users,
    super.searchQuery,
    super.roleFilter,
    super.statusFilter,
  });

  @override
  bool get isSaving => true;
}

final class AdminUsersFailure extends AdminUsersState {
  const AdminUsersFailure({
    super.users,
    super.searchQuery,
    super.roleFilter,
    super.statusFilter,
    super.errorMessage,
  });
}
