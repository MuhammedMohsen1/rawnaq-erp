import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
    String? deviceToken,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock credentials - in development, any valid email format will work
    if (email.contains('@') && password.length >= 6) {
      final mockUser = {
        'id': '1',
        'email': email,
        'name': 'مدير المشاريع',
        'phone': '+966501234567',
        'avatar': null,
        'role': 'manager',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      };

      return Right({
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': mockUser,
      });
    } else {
      return const Left(UnauthorizedFailure(message: 'بيانات الدخول غير صحيحة'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email.contains('@')) {
      return const Right(null);
    } else {
      return const Left(ValidationFailure(message: 'Invalid email address'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final mockUser = User(
      id: '1',
      email: 'admin@rawnaq.com',
      name: 'مدير المشاريع',
      phone: '+966501234567',
      avatar: null,
      role: 'manager',
      isActive: true,
      createdAt: DateTime.now(),
    );

    return Right(mockUser);
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      // This will check if we have a stored token
      return const Right(
        true,
      ); // For mock, we'll let the storage service handle this
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to check login status'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }
}
