import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceProvider extends ChangeNotifier {
  AppearanceProvider(this._preferences)
    : _mode = ThemeMode.values.firstWhere(
        (mode) => mode.name == _preferences.getString(_storageKey),
        orElse: () => ThemeMode.system,
      );

  static const _storageKey = 'appearance_mode';
  final SharedPreferences _preferences;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    if (!await _preferences.setString(_storageKey, mode.name)) {
      throw StateError('Could not persist the appearance preference.');
    }
  }
}
