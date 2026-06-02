import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/admin_users_api_datasource.dart';
import 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  final AdminUsersApiDataSource _dataSource;

  AdminUsersCubit({AdminUsersApiDataSource? dataSource})
    : _dataSource = dataSource ?? AdminUsersApiDataSource(),
      super(const AdminUsersInitial());

  Future<void> loadUsers() async {
    emit(
      AdminUsersLoading(
        users: state.users,
        searchQuery: state.searchQuery,
        roleFilter: state.roleFilter,
        statusFilter: state.statusFilter,
      ),
    );
    try {
      final users = await _dataSource.getUsers();
      emit(
        AdminUsersLoaded(
          users: users,
          searchQuery: state.searchQuery,
          roleFilter: state.roleFilter,
          statusFilter: state.statusFilter,
        ),
      );
    } catch (e) {
      emit(
        AdminUsersFailure(
          users: state.users,
          searchQuery: state.searchQuery,
          roleFilter: state.roleFilter,
          statusFilter: state.statusFilter,
          errorMessage: 'فشل تحميل المستخدمين: ${e.toString()}',
        ),
      );
    }
  }

  void updateSearch(String query) {
    emit(_copyState(searchQuery: query));
  }

  void updateRoleFilter(String role) {
    emit(_copyState(roleFilter: role));
  }

  void updateStatusFilter(String status) {
    emit(_copyState(statusFilter: status));
  }

  Future<void> createUser({
    required String email,
    required String name,
    required String password,
    required String role,
    required String accountStatus,
    String? phone,
    List<String>? adminSubRoles,
  }) async {
    await _mutate(
      successMessage: AppConstants.createSuccess,
      action: () => _dataSource.createUser({
        'email': email,
        'name': name,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'password': password,
        'role': _toApiEnum(role),
        if (role == AppConstants.adminRole)
          'adminSubRoles': adminSubRoles?.map(_toApiEnum).toList() ?? [],
        'accountStatus': accountStatus,
      }),
    );
  }

  Future<void> updateUser({
    required User user,
    required String name,
    required String role,
    required String accountStatus,
    String? phone,
    String? password,
    List<String>? adminSubRoles,
  }) async {
    await _mutate(
      successMessage: AppConstants.updateSuccess,
      action: () => _dataSource.updateUser(user.id, {
        'name': name,
        'phone': phone?.trim().isEmpty ?? true ? null : phone!.trim(),
        'role': _toApiEnum(role),
        if (role == AppConstants.adminRole)
          'adminSubRoles': adminSubRoles?.map(_toApiEnum).toList() ?? [],
        if (role != AppConstants.adminRole) 'adminSubRoles': <String>[],
        'accountStatus': accountStatus,
        if (password != null && password.isNotEmpty) 'password': password,
      }),
    );
  }

  Future<void> updateUserStatus(User user, String accountStatus) async {
    await _mutate(
      successMessage: AppConstants.updateSuccess,
      action: () =>
          _dataSource.updateUser(user.id, {'accountStatus': accountStatus}),
    );
  }

  Future<void> deleteUser(User user) async {
    emit(_savingState());
    try {
      await _dataSource.deleteUser(user.id);
      final updatedUsers = state.users
          .where((item) => item.id != user.id)
          .toList();
      emit(
        AdminUsersLoaded(
          users: updatedUsers,
          searchQuery: state.searchQuery,
          roleFilter: state.roleFilter,
          statusFilter: state.statusFilter,
          successMessage: AppConstants.deleteSuccess,
        ),
      );
    } catch (e) {
      emit(
        AdminUsersFailure(
          users: state.users,
          searchQuery: state.searchQuery,
          roleFilter: state.roleFilter,
          statusFilter: state.statusFilter,
          errorMessage: 'فشل حذف المستخدم: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _mutate({
    required String successMessage,
    required Future<User> Function() action,
  }) async {
    emit(_savingState());
    try {
      await action();
      final users = await _dataSource.getUsers();
      emit(
        AdminUsersLoaded(
          users: users,
          searchQuery: state.searchQuery,
          roleFilter: state.roleFilter,
          statusFilter: state.statusFilter,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      emit(
        AdminUsersFailure(
          users: state.users,
          searchQuery: state.searchQuery,
          roleFilter: state.roleFilter,
          statusFilter: state.statusFilter,
          errorMessage: 'تعذر حفظ بيانات المستخدم: ${e.toString()}',
        ),
      );
    }
  }

  String _toApiEnum(String value) => value.toUpperCase();

  AdminUsersState _savingState() {
    return AdminUsersSaving(
      users: state.users,
      searchQuery: state.searchQuery,
      roleFilter: state.roleFilter,
      statusFilter: state.statusFilter,
    );
  }

  AdminUsersState _copyState({
    List<User>? users,
    String? searchQuery,
    String? roleFilter,
    String? statusFilter,
  }) {
    final currentUsers = users ?? state.users;
    final currentSearchQuery = searchQuery ?? state.searchQuery;
    final currentRoleFilter = roleFilter ?? state.roleFilter;
    final currentStatusFilter = statusFilter ?? state.statusFilter;

    return switch (state) {
      AdminUsersInitial() => AdminUsersInitial(),
      AdminUsersLoading() => AdminUsersLoading(
        users: currentUsers,
        searchQuery: currentSearchQuery,
        roleFilter: currentRoleFilter,
        statusFilter: currentStatusFilter,
      ),
      AdminUsersLoaded() => AdminUsersLoaded(
        users: currentUsers,
        searchQuery: currentSearchQuery,
        roleFilter: currentRoleFilter,
        statusFilter: currentStatusFilter,
        errorMessage: state.errorMessage,
        successMessage: state.successMessage,
      ),
      AdminUsersSaving() => AdminUsersSaving(
        users: currentUsers,
        searchQuery: currentSearchQuery,
        roleFilter: currentRoleFilter,
        statusFilter: currentStatusFilter,
      ),
      AdminUsersFailure() => AdminUsersFailure(
        users: currentUsers,
        searchQuery: currentSearchQuery,
        roleFilter: currentRoleFilter,
        statusFilter: currentStatusFilter,
        errorMessage: state.errorMessage,
      ),
    };
  }
}
