import 'package:flutter/material.dart';
import '../../../../core/constants/endpoints.dart';

/// Example usage of the login API
///
/// This demonstrates how to use the login functionality:
///
/// 1. Endpoint: ApiEndpoints.login (which resolves to '/login')
/// 2. Base URL: ApiEndpoints.baseUrl (which is 'http://127.0.0.1:3000')
/// 3. Full URL: http://127.0.0.1:3000/login
///
/// Request Body:
/// ```json
/// {
///   "email": "manager.burger@example.com",
///   "password": "password123"
/// }
/// ```
///
/// Expected Response:
/// ```json
/// {
///   "success": true,
///   "message": "تم تسجيل الدخول بنجاح",
///   "user": {
///     "id": "50d9a9c7-7391-420b-9ad5-41cf4521226f",
///     "name": "Burger Joint Manager",
///     "email": "manager.burger@example.com",
///     "phone": "+201234567896",
///     "role": "RESTAURANT_ADMIN",
///     "isActive": true,
///     "createdAt": "2025-06-22T14:44:09.806Z",
///     "updatedAt": "2025-06-22T17:38:09.322Z",
///     "lastLoginAt": "2025-06-22T17:38:09.322Z"
///   },
///   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
/// }
/// ```
///
/// The login implementation:
/// - Uses AuthRepositoryImpl which calls DioHelper.postData
/// - Automatically stores the token and user data in local storage
/// - Returns structured data using LoginResponse model
/// - Handles authentication errors appropriately
///
/// To use this in your UI:
/// ```dart
/// final authBloc = context.read<AuthBloc>();
/// authBloc.add(LoginEvent(
///   email: 'manager.burger@example.com',
///   password: 'password123',
/// ));
/// ```
class LoginApiExample extends StatelessWidget {
  const LoginApiExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login API Configuration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Base URL:', ApiEndpoints.baseUrl),
            _buildInfoRow('Login Endpoint:', ApiEndpoints.login),
            _buildInfoRow(
              'Full URL:',
              '${ApiEndpoints.baseUrl}${ApiEndpoints.login}',
            ),
            const SizedBox(height: 16),
            Text(
              'Test Credentials:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Email:', 'manager.burger@example.com'),
            _buildInfoRow('Password:', 'password123'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
