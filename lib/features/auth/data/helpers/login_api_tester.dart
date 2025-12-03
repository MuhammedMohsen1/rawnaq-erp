import 'package:flutter/foundation.dart';
import '../../../../core/constants/endpoints.dart';
import '../../../../core/constants/test_credentials.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/repositories/auth_repository.dart';

/// Helper class for testing the login API
class LoginApiTester {
  static final AuthRepository _authRepository = getIt<AuthRepository>();

  /// Test login with default credentials
  static Future<void> testLoginWithDefaultCredentials() async {
    final credentials = TestCredentials.getDefaultCredentials();
    await testLogin(
      email: credentials['email']!,
      password: credentials['password']!,
    );
  }

  /// Test login with custom credentials
  static Future<void> testLogin({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('🔐 Testing login API...');
      print('📧 Email: $email');
      print('🌐 Endpoint: ${ApiEndpoints.baseUrl}${ApiEndpoints.login}');
      print('');
    }

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('❌ Login failed: ${failure.message}');
        }
      },
      (data) {
        if (kDebugMode) {
          print('✅ Login successful!');
          print('📱 Response: $data');
          if (data['user'] != null) {
            print('👤 User: ${data['user']['name']} (${data['user']['role']})');
          }
          if (data['token'] != null) {
            final token = data['token'] as String;
            print('🔑 Token: ${token.substring(0, 20)}...');
          }
        }
      },
    );
  }

  /// Test logout
  static Future<void> testLogout() async {
    if (kDebugMode) {
      print('🚪 Testing logout API...');
    }

    final result = await _authRepository.logout();

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('❌ Logout failed: ${failure.message}');
        }
      },
      (_) {
        if (kDebugMode) {
          print('✅ Logout successful!');
        }
      },
    );
  }

  /// Check if user is logged in
  static Future<void> checkLoginStatus() async {
    final result = await _authRepository.isLoggedIn();

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('❌ Failed to check login status: ${failure.message}');
        }
      },
      (isLoggedIn) {
        if (kDebugMode) {
          print(
            '🔍 Login status: ${isLoggedIn ? 'Logged in' : 'Not logged in'}',
          );
        }
      },
    );
  }
}
