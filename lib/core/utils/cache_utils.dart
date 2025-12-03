import '../storage/storage_service.dart';
import '../di/injection_container.dart';

/// Utility class for managing cached user data and tokens
class CacheUtils {
  static StorageService get _storageService {
    try {
      return getIt<StorageService>();
    } catch (e) {
      throw Exception(
        'StorageService not registered in DI. Make sure setupDI() is called before using CacheUtils.',
      );
    }
  }

  /// Clear user authentication token
  static Future<void> clearToken() async {
    await _storageService.clearToken();
  }

  /// Clear user data from cache
  static Future<void> clearUserData() async {
    await _storageService.clearUserData();
  }

  /// Clear refresh token
  static Future<void> clearRefreshToken() async {
    await _storageService.clearRefreshToken();
  }

  /// Clear all user-related data (token, user data, refresh token)
  static Future<void> clearAllUserData() async {
    await Future.wait([
      _storageService.clearToken(),
      _storageService.clearUserData(),
      _storageService.clearRefreshToken(),
    ]);
  }

  /// Clear all cached data
  static Future<void> clearAll() async {
    await _storageService.clearAll();
  }

  /// Check if user is logged in (has token)
  static Future<bool> isLoggedIn() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get current user data
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    return await _storageService.getUserData();
  }

  /// Get current token
  static Future<String?> getCurrentToken() async {
    return await _storageService.getToken();
  }

  // ========== FCM Token Caching ==========

  /// Cache FCM device token
  static Future<void> cacheFCMToken(String token) async {
    await _storageService.setFCMToken(token);
  }

  /// Get cached FCM device token
  static Future<String?> getCachedFCMToken() async {
    return await _storageService.getFCMToken();
  }

  /// Clear cached FCM token
  static Future<void> clearFCMToken() async {
    await _storageService.clearFCMToken();
  }

  /// Check if FCM token has changed
  static Future<bool> hasFCMTokenChanged(String newToken) async {
    final cachedToken = await getCachedFCMToken();
    return cachedToken != newToken;
  }

  /// Cache timestamp of last FCM token refresh
  static Future<void> cacheFCMTokenRefreshTime() async {
    await _storageService.setFCMTokenRefreshTime(
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Get last FCM token refresh time
  static Future<DateTime?> getLastFCMTokenRefreshTime() async {
    final timestampStr = await _storageService.getFCMTokenRefreshTime();
    if (timestampStr != null) {
      try {
        final timestamp = int.parse(timestampStr);
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Check if FCM token should be refreshed (if it's been more than 24 hours)
  static Future<bool> shouldRefreshFCMToken() async {
    final lastRefresh = await getLastFCMTokenRefreshTime();
    if (lastRefresh == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastRefresh);
    return difference.inHours >= 24; // Refresh if it's been more than 24 hours
  }
}
