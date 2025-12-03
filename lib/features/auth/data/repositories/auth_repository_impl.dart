import 'dart:developer' show log;
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_helper.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/endpoints.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
    String? deviceToken,
  }) async {
    try {
      log('🚩 Repository: Starting login request');
      final loginData = {'email': email, 'password': password};

      // Add device token if provided
      if (deviceToken != null && deviceToken.isNotEmpty) {
        loginData['deviceToken'] = deviceToken;
        try {
          loginData['deviceType'] = Platform.isAndroid
              ? 'ANDROID'
              : Platform.isIOS
              ? 'IOS'
              : 'WEB';
        } catch (e) {
          // Fallback for web or unsupported platforms
          loginData['deviceType'] = 'WEB';
        }
        log(
          '🚩 Repository: Including FULL device token in login request: $deviceToken',
        );
      } else {
        log(
          '🚩 Repository: No device token provided (deviceToken: $deviceToken)',
        );
      }

      log('🚩 Repository: Final login data keys: ${loginData.keys.toList()}');

      final response = await DioHelper.postData(
        url: ApiEndpoints.login,
        data: loginData,
      );

      log('🚩 Repository: Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // Parse the response to validate structure
        final loginResponse = LoginResponse.fromJson(data);

        // Store the token and user data
        final storageService = getIt<StorageService>();
        await storageService.setToken(loginResponse.token);
        await storageService.setUserData(loginResponse.user.toJson());

        log('🚩 Repository: Login successful');
        return Right(data);
      } else {
        log('🚩 Repository: Login failed with status: ${response.statusCode}');
        return const Left(ServerFailure(message: 'فشل تسجيل الدخول'));
      }
    } on DioException catch (e) {
      log(
        '🚩 Repository: DioException caught: ${e.response?.statusCode} - ${e.message}',
      );

      // Extract error message from response
      String errorMessage = 'حدث خطأ غير متوقع';
      if (e.response?.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'].toString();
          // Handle specific API error format
          if (errorMessage.contains('MESSAGES.INVALID_CREDENTIALS:')) {
            errorMessage = errorMessage
                .split('MESSAGES.INVALID_CREDENTIALS:')
                .last
                .trim();
          } else if (errorMessage == 'MESSAGES.INVALID_CREDENTIALS') {
            errorMessage = 'بريد إلكتروني أو كلمة مرور غير صحيحين';
          }
        }
      }

      if (e.response?.statusCode == 401) {
        log('🚩 Repository: 401 error - returning UnauthorizedFailure');
        return Left(
          UnauthorizedFailure(
            message: errorMessage.isNotEmpty
                ? errorMessage
                : 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
          ),
        );
      } else if (e.response?.statusCode == 404) {
        log(
          '🚩 Repository: 404 error - returning UnauthorizedFailure for login',
        );
        return Left(
          UnauthorizedFailure(
            message: errorMessage.isNotEmpty
                ? errorMessage
                : 'بريد إلكتروني أو كلمة مرور غير صحيحين',
          ),
        );
      } else if (e.response?.statusCode == 400) {
        log('🚩 Repository: 400 error - returning ValidationFailure');
        return Left(
          ValidationFailure(
            message: errorMessage.isNotEmpty
                ? errorMessage
                : 'البيانات المدخلة غير صحيحة',
          ),
        );
      } else {
        log('🚩 Repository: Network error - returning NetworkFailure');
        return const Left(
          NetworkFailure(message: 'حدث خطأ في الاتصال بالشبكة'),
        );
      }
    } catch (e) {
      log('🚩 Repository: Unexpected error caught: $e');
      return const Left(
        UnknownFailure(message: 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear local storage first
      final storageService = getIt<StorageService>();
      await storageService.clearToken();
      await storageService.clearUserData();

      // // Then call the API (if it fails, we still want to clear local data)
      // await DioHelper.postData(url: ApiEndpoints.logout);
      return const Right(null);
    } catch (e) {
      // Even if the API call fails, we still want to clear local data
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      final response = await DioHelper.postData(
        url: ApiEndpoints.resetPassword,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return const Left(
          ServerFailure(message: 'فشل إعادة تعيين كلمة المرور'),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Left(
          NotFoundFailure(message: 'البريد الإلكتروني غير موجود'),
        );
      } else {
        return const Left(
          NetworkFailure(message: 'حدث خطأ في الاتصال بالشبكة'),
        );
      }
    } catch (e) {
      return const Left(
        UnknownFailure(message: 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final response = await DioHelper.getData(
        url: ApiEndpoints.getCurrentUser,
      );

      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        final user = User.fromJson(userData['user']);
        return Right(user);
      } else {
        return const Left(ServerFailure(message: 'فشل جلب بيانات المستخدم'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(UnauthorizedFailure(message: 'غير مصرح'));
      } else {
        return const Left(
          NetworkFailure(message: 'حدث خطأ في الاتصال بالشبكة'),
        );
      }
    } catch (e) {
      return const Left(
        UnknownFailure(message: 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final storageService = getIt<StorageService>();
      final token = await storageService.getToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return const Left(
        CacheFailure(message: 'فشل التحقق من حالة تسجيل الدخول'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final storageService = getIt<StorageService>();
      final refreshToken = await storageService.getRefreshToken();

      if (refreshToken == null) {
        return const Left(UnauthorizedFailure(message: 'لا يوجد رمز تحديث'));
      }

      final response = await DioHelper.postData(
        url: ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['token'] as String;
        await storageService.setToken(newToken);
        return const Right(null);
      } else {
        return const Left(UnauthorizedFailure(message: 'فشل تحديث الرمز'));
      }
    } catch (e) {
      return const Left(
        UnknownFailure(message: 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا'),
      );
    }
  }
}
