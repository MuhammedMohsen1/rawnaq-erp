import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';

/// Extended user entity for admin management
class AdminUser extends Equatable {
  final User user;
  final int? projectCount;
  final DateTime? lastActivity;

  const AdminUser({
    required this.user,
    this.projectCount,
    this.lastActivity,
  });

  factory AdminUser.fromUser(User user, {int? projectCount, DateTime? lastActivity}) {
    return AdminUser(
      user: user,
      projectCount: projectCount,
      lastActivity: lastActivity,
    );
  }

  @override
  List<Object?> get props => [user, projectCount, lastActivity];
}

