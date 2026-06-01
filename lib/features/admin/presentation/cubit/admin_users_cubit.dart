import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/admin_users_api_datasource.dart';
import 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  final AdminUsersApiDataSource _dataSource;

  AdminUsersCubit({AdminUsersApiDataSource? dataSource})
    : _dataSource = dataSource ?? AdminUsersApiDataSource(),
      super(const AdminUsersState());

  Future<void> loadUsers() async {
    emit(state.copyWith(status: AdminUsersStatus.loading, clearMessages: true));
    try {
      final users = await _dataSource.getUsers();
      emit(state.copyWith(status: AdminUsersStatus.loaded, users: users));
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminUsersStatus.error,
          errorMessage: 'فشل تحميل المستخدمين: ${e.toString()}',
        ),
      );
    }
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query, clearMessages: true));
  }

  void updateRoleFilter(String role) {
    emit(state.copyWith(roleFilter: role, clearMessages: true));
  }

  void updateStatusFilter(String status) {
    emit(state.copyWith(statusFilter: status, clearMessages: true));
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
    emit(state.copyWith(status: AdminUsersStatus.saving, clearMessages: true));
    try {
      await _dataSource.deleteUser(user.id);
      final updatedUsers = state.users
          .where((item) => item.id != user.id)
          .toList();
      emit(
        state.copyWith(
          status: AdminUsersStatus.loaded,
          users: updatedUsers,
          successMessage: AppConstants.deleteSuccess,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminUsersStatus.loaded,
          errorMessage: 'فشل حذف المستخدم: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _mutate({
    required String successMessage,
    required Future<User> Function() action,
  }) async {
    emit(state.copyWith(status: AdminUsersStatus.saving, clearMessages: true));
    try {
      await action();
      final users = await _dataSource.getUsers();
      emit(
        state.copyWith(
          status: AdminUsersStatus.loaded,
          users: users,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminUsersStatus.loaded,
          errorMessage: 'تعذر حفظ بيانات المستخدم: ${e.toString()}',
        ),
      );
    }
  }

  String _toApiEnum(String value) => value.toUpperCase();
}
