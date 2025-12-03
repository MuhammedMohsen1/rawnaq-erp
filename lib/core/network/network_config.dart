import 'package:rawnaq/core/constants/endpoints.dart';
import 'package:flutter/foundation.dart';

class NetworkConfig {
  // Environment-specific base URLs
  static const String _devBaseUrl = ApiEndpoints.baseUrl;
  static const String _devAltBaseUrl = ApiEndpoints.baseUrl;
  static const String _prodBaseUrl = 'https://beenedeek.com/api/v1';

  /// Get the appropriate base URL based on environment and platform
  static String get baseUrl {
    if (kDebugMode) {
      // Development environment
      return kIsWeb ? _devBaseUrl : _devAltBaseUrl;
    } else {
      // Production environment
      return _prodBaseUrl;
    }
  }

  /// Alternative URLs to try if primary fails
  static List<String> get fallbackUrls => [
    'http://localhost:3001',
    'http://127.0.0.1:3001',
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:8000',
    'http://127.0.0.1:8000',
  ];

  /// Check if we're running on web platform
  static bool get isWeb => kIsWeb;

  /// Get user-friendly error message for network issues
  static String getNetworkErrorMessage(String originalError) {
    if (originalError.contains('XMLHttpRequest') ||
        originalError.contains('network')) {
      return '''
Network connection failed. This is likely due to:

1. 🔗 Backend server not running on $baseUrl
2. 🚫 CORS not configured on your backend server
3. 🔄 Port conflict between Flutter web and backend
4. 🌐 Browser blocking the request

Quick fixes:
• Check if your backend server is running
• Try changing the base URL in endpoints.dart
• Add CORS headers to your backend
• Run Flutter web on different port: flutter run -d chrome --web-port 8080

See NETWORK_TROUBLESHOOTING.md for detailed solutions.
      ''';
    }
    return originalError;
  }

  /// Development helper to test different URLs
  static Future<String?> findWorkingUrl() async {
    // This would need to be implemented with actual HTTP tests
    // For now, just return the default
    if (kDebugMode) {
      print('🔍 Testing URLs: ${fallbackUrls.join(', ')}');
      print('💡 Recommended: Configure CORS on your backend server');
    }
    return baseUrl;
  }
}
