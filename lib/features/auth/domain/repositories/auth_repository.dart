import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
    String? deviceToken,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> resetPassword({required String email});

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, bool>> isLoggedIn();

  Future<Either<Failure, void>> refreshToken();
}
