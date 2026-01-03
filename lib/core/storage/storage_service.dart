import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

abstract class StorageService {
  Future<void> setToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();

  Future<void> setRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearRefreshToken();

  Future<void> setSessionId(String sessionId);
  Future<String?> getSessionId();
  Future<void> clearSessionId();

  Future<void> setUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> clearUserData();

  Future<void> setLanguage(String language);
  Future<String?> getLanguage();

  Future<void> setTheme(String theme);
  Future<String?> getTheme();

  Future<void> setOnboardingCompleted(bool completed);
  Future<bool> getOnboardingCompleted();

  // FCM Token methods
  Future<void> setFCMToken(String token);
  Future<String?> getFCMToken();
  Future<void> clearFCMToken();

  Future<void> setFCMTokenRefreshTime(String timestamp);
  Future<String?> getFCMTokenRefreshTime();
  Future<void> clearFCMTokenRefreshTime();

  Future<void> clearAll();
}

class StorageServiceImpl implements StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> setToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString(AppConstants.tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  @override
  Future<void> setRefreshToken(String token) async {
    await _prefs.setString(AppConstants.refreshTokenKey, token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> clearRefreshToken() async {
    await _prefs.remove(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> setSessionId(String sessionId) async {
    await _prefs.setString(AppConstants.sessionIdKey, sessionId);
  }

  @override
  Future<String?> getSessionId() async {
    return _prefs.getString(AppConstants.sessionIdKey);
  }

  @override
  Future<void> clearSessionId() async {
    await _prefs.remove(AppConstants.sessionIdKey);
  }

  @override
  Future<void> setUserData(Map<String, dynamic> userData) async {
    final jsonString = json.encode(userData);
    await _prefs.setString(AppConstants.userDataKey, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = _prefs.getString(AppConstants.userDataKey);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> clearUserData() async {
    await _prefs.remove(AppConstants.userDataKey);
  }

  @override
  Future<void> setLanguage(String language) async {
    await _prefs.setString(AppConstants.languageKey, language);
  }

  @override
  Future<String?> getLanguage() async {
    return _prefs.getString(AppConstants.languageKey);
  }

  @override
  Future<void> setTheme(String theme) async {
    await _prefs.setString(AppConstants.themeKey, theme);
  }

  @override
  Future<String?> getTheme() async {
    return _prefs.getString(AppConstants.themeKey);
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(AppConstants.onboardingKey, completed);
  }

  @override
  Future<bool> getOnboardingCompleted() async {
    return _prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  // FCM Token methods
  @override
  Future<void> setFCMToken(String token) async {
    await _prefs.setString(AppConstants.fcmTokenKey, token);
  }

  @override
  Future<String?> getFCMToken() async {
    return _prefs.getString(AppConstants.fcmTokenKey);
  }

  @override
  Future<void> clearFCMToken() async {
    await _prefs.remove(AppConstants.fcmTokenKey);
  }

  @override
  Future<void> setFCMTokenRefreshTime(String timestamp) async {
    await _prefs.setString(AppConstants.fcmTokenRefreshTimeKey, timestamp);
  }

  @override
  Future<String?> getFCMTokenRefreshTime() async {
    return _prefs.getString(AppConstants.fcmTokenRefreshTimeKey);
  }

  @override
  Future<void> clearFCMTokenRefreshTime() async {
    await _prefs.remove(AppConstants.fcmTokenRefreshTimeKey);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
