import 'dart:developer' show log;
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_helper.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/endpoints.dart';
import '../../../../core/utils/response_code_translator.dart';
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
        final responseData = response.data as Map<String, dynamic>;

        // Check if data field exists
        if (!responseData.containsKey('data') || responseData['data'] == null) {
          log('🚩 Repository: Missing data field in response');
          return const Left(
            ServerFailure(message: 'استجابة غير صحيحة من الخادم'),
          );
        }

        // Parse the response to validate structure (handles data wrapper)
        final loginResponse = LoginResponse.fromJson(responseData);

        // Store the token, refreshToken, sessionId and user data
        final storageService = getIt<StorageService>();
        await storageService.setToken(loginResponse.token);
        await storageService.setRefreshToken(loginResponse.refreshToken);
        await storageService.setSessionId(loginResponse.sessionId);
        await storageService.setUserData(loginResponse.user.toJson());

        log(
          '🚩 Repository: Login successful - stored token, refreshToken, and sessionId',
        );
        // Return the data from the data field for backward compatibility
        final dataField = responseData['data'] as Map<String, dynamic>;
        return Right(dataField);
      } else {
        log('🚩 Repository: Login failed with status: ${response.statusCode}');
        return const Left(ServerFailure(message: 'فشل تسجيل الدخول'));
      }
    } on DioException catch (e) {
      log(
        '🚩 Repository: DioException caught - Type: ${e.type}, Status: ${e.response?.statusCode}, Message: ${e.message}',
      );
      log('🚩 Repository: Request URL: ${e.requestOptions.uri}');
      log('🚩 Repository: Request Method: ${e.requestOptions.method}');
      if (e.error != null) {
        log('🚩 Repository: Error: ${e.error}');
      }

      // Handle connection errors (no status code)
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        log('🚩 Repository: Connection error - no status code');
        return const Left(
          NetworkFailure(
            message: 'فشل الاتصال بالخادم. تأكد من أن الخادم يعمل',
          ),
        );
      }

      // Extract error code from response and translate it
      String errorMessage = 'حدث خطأ غير متوقع';
      if (e.response?.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        // Try to get code first, fallback to message for backward compatibility
        String? errorCode;
        if (responseData.containsKey('code')) {
          errorCode = responseData['code'].toString();
        } else if (responseData.containsKey('message')) {
          // Support legacy message field - check if it's a code pattern
          final msg = responseData['message'].toString();
          if (msg.contains('_') && msg == msg.toUpperCase()) {
            // Looks like a code (e.g., "ORDER_CREATED")
            errorCode = msg;
          } else {
            // It's a regular message, use it directly
            errorMessage = msg;
          }
        }

        if (errorCode != null) {
          errorMessage = ResponseCodeTranslator.translate(errorCode);
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
      final storageService = getIt<StorageService>();
      final sessionId = await storageService.getSessionId();

      // Call the API with sessionId (if it fails, we still want to clear local data)
      try {
        if (sessionId != null) {
          await DioHelper.postData(
            url: ApiEndpoints.logout,
            data: {'sessionId': sessionId},
          );
        }
      } catch (e) {
        log('🚩 Repository: Logout API call failed: $e');
        // Continue to clear local storage even if API call fails
      }

      // Clear local storage
      await storageService.clearToken();
      await storageService.clearRefreshToken();
      await storageService.clearSessionId();
      await storageService.clearUserData();

      return const Right(null);
    } catch (e) {
      // Even if everything fails, try to clear local data
      try {
        final storageService = getIt<StorageService>();
        await storageService.clearToken();
        await storageService.clearRefreshToken();
        await storageService.clearSessionId();
        await storageService.clearUserData();
      } catch (_) {
        // Ignore errors during cleanup
      }
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
      final refreshTokenValue = await storageService.getRefreshToken();
      final sessionId = await storageService.getSessionId();

      if (refreshTokenValue == null) {
        return const Left(UnauthorizedFailure(message: 'لا يوجد رمز تحديث'));
      }

      if (sessionId == null) {
        return const Left(UnauthorizedFailure(message: 'لا يوجد معرف الجلسة'));
      }

      final response = await DioHelper.postData(
        url: ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshTokenValue, 'sessionId': sessionId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        // Extract data from the nested data field
        final data = responseData['data'] as Map<String, dynamic>;
        final newToken = data['token'] as String;
        final newRefreshToken = data['refreshToken'] as String;
        final newSessionId = data['sessionId'] as String;

        // Store new tokens and sessionId
        await storageService.setToken(newToken);
        await storageService.setRefreshToken(newRefreshToken);
        await storageService.setSessionId(newSessionId);

        // Update user data if provided
        if (data.containsKey('user')) {
          await storageService.setUserData(
            data['user'] as Map<String, dynamic>,
          );
        }

        log('🚩 Repository: Token refresh successful');
        return const Right(null);
      } else {
        return const Left(UnauthorizedFailure(message: 'فشل تحديث الرمز'));
      }
    } on DioException catch (e) {
      log(
        '🚩 Repository: DioException during token refresh: ${e.response?.statusCode}',
      );
      if (e.response?.statusCode == 401) {
        return const Left(
          UnauthorizedFailure(message: 'انتهت صلاحية رمز التحديث'),
        );
      }
      return const Left(
        UnknownFailure(message: 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا'),
      );
    } catch (e) {
      log('🚩 Repository: Unexpected error during token refresh: $e');
      return const Left(
        UnknownFailure(message: 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا'),
      );
    }
  }
}
