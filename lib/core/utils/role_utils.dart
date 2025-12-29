import '../../features/auth/domain/entities/user.dart';
import '../constants/app_constants.dart';

/// Utility class for role-based access control
class RoleUtils {
  /// Check if user can access admin features
  static bool canAccessAdmin(User user) {
    return user.isAdmin;
  }

  /// Check if user can manage users
  static bool canManageUsers(User user) {
    return user.isAdmin && (user.isSystemAdmin || user.adminSubRoles == null);
  }

  /// Check if user can manage projects
  static bool canManageProjects(User user) {
    return user.isAdmin || user.isManager;
  }

  /// Check if user can view all projects
  static bool canViewAllProjects(User user) {
    return user.isAdmin || user.isManager || user.isSeniorEngineer;
  }

  /// Check if user can only view assigned projects
  static bool canOnlyViewAssignedProjects(User user) {
    return user.isJuniorEngineer;
  }

  /// Check if user can approve/review
  static bool canApprove(User user) {
    return user.isAdmin || user.isSeniorEngineer || user.isTechnicalAdmin;
  }

  /// Check if user can access financial data
  static bool canAccessFinancial(User user) {
    return user.isAdmin || user.isManager || user.isFinancialAdmin;
  }

  /// Get user's display role name
  static String getRoleDisplayName(User user) {
    switch (user.role) {
      case AppConstants.adminRole:
        if (user.adminSubRoles != null && user.adminSubRoles!.isNotEmpty) {
          return 'Admin (${user.adminSubRoles!.join(', ')})';
        }
        return 'System Admin';
      case AppConstants.managerRole:
        return 'Manager';
      case AppConstants.seniorEngineerRole:
        return 'Senior Engineer';
      case AppConstants.juniorEngineerRole:
        return 'Junior Engineer';
      default:
        return user.role;
    }
  }
}

