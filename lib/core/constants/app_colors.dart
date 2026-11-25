import 'package:flutter/material.dart';

class AppColors {
  const AppColors._(this.brightness);

  static const light = AppColors._(Brightness.light);
  static const dark = AppColors._(Brightness.dark);

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  final Brightness brightness;
  bool get _isDark => brightness == Brightness.dark;

  // Workspace and panel surfaces.
  Color get scaffoldBackground =>
      _isDark ? const Color(0xFF161B22) : const Color(0xFFFCFCFC);
  Color get cardBackground =>
      _isDark ? const Color(0xFF1C2128) : const Color(0xFFFFFFFF);
  Color get surfaceColor =>
      _isDark ? const Color(0xFF21262D) : const Color(0xFFF7F7F7);
  Color get sidebarBackground =>
      _isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
  Color get sectionHeader => _isDark ? surfaceColor : cardBackground;
  Color get background => scaffoldBackground;
  Color get surface =>
      _isDark ? const Color(0xFF1C2128) : const Color(0xFFFFFFFF);

  // Primary accent and state surfaces.
  Color get primary =>
      _isDark ? const Color(0xFF3B82F6) : const Color(0xFF1D4ED8);
  Color get primaryLight =>
      _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
  Color get primaryDark =>
      _isDark ? const Color(0xFF2563EB) : const Color(0xFF1E40AF);
  Color get selectedSurface => const Color(0x263B82F6);
  Color get selectedSurfaceStrong => const Color(0x403B82F6);
  Color get hoverSurface =>
      _isDark ? const Color(0x1A3B82F6) : const Color(0x0D000000);
  Color get buttonPrimary => const Color(0xFF1D4ED8);
  Color get buttonHover =>
      _isDark ? const Color(0xFF2563EB) : const Color(0xFF1E40AF);

  // Secondary colors
  Color get secondary =>
      _isDark ? const Color(0xFF3B82F6) : const Color(0xFF1D4ED8);
  Color get secondaryLight =>
      _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);

  // Text colors
  Color get textPrimary =>
      _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF171717);
  Color get textSecondary =>
      _isDark ? const Color(0xFF8B949E) : const Color(0xFF333333);
  Color get textMuted =>
      _isDark ? const Color(0xFF6E7681) : const Color(0xFF555555);
  Color get textDisabled =>
      _isDark ? const Color(0xFF484F58) : const Color(0xFF666666);

  // Status colors
  Color get statusActive =>
      _isDark ? const Color(0xFF3B82F6) : const Color(0xFF1D4ED8); // Blue
  Color get statusCompleted =>
      _isDark ? const Color(0xFF22C55E) : const Color(0xFF166534); // Green
  Color get statusDelayed =>
      _isDark ? const Color(0xFFEF4444) : const Color(0xFFB91C1C); // Red
  Color get statusOnHold =>
      _isDark ? const Color(0xFFF59E0B) : const Color(0xFF92400E); // Amber

  // Semantic colors
  Color get success =>
      _isDark ? const Color(0xFF22C55E) : const Color(0xFF166534);
  Color get warning =>
      _isDark ? const Color(0xFFF59E0B) : const Color(0xFF92400E);
  Color get error =>
      _isDark ? const Color(0xFFEF4444) : const Color(0xFFB91C1C);
  Color get info => _isDark ? const Color(0xFF3B82F6) : const Color(0xFF1D4ED8);
  Color get delete =>
      _isDark ? const Color(0xFFEF4444) : const Color(0xFFB91C1C);

  // Border and dividers
  Color get border =>
      _isDark ? const Color(0xFF30363D) : const Color(0xFFD8D8D8);
  Color get divider =>
      _isDark ? const Color(0xFF21262D) : const Color(0xFFE6E6E6);

  // Basic colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  Color get grey => _isDark ? const Color(0xFF8B949E) : const Color(0xFF555555);
  Color get lightGrey =>
      _isDark ? const Color(0xFF6E7681) : const Color(0xFF555555);
  Color get darkGrey =>
      _isDark ? const Color(0xFF484F58) : const Color(0xFFDDDDDD);

  // Shadow colors
  Color get shadow =>
      _isDark ? const Color(0x94000000) : const Color(0x1A000000);

  // Table colors
  Color get tableHeader =>
      _isDark ? const Color(0xFF21262D) : const Color(0xFFF5F5F5);
  Color get tableRowEven =>
      _isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
  Color get tableRowOdd =>
      _isDark ? const Color(0xFF0D1117) : const Color(0xFFFAFAFA);
  Color get tableRowHover =>
      _isDark ? const Color(0xFF1F2937) : const Color(0xFFEEEEEE);

  // Input colors
  Color get inputBackground =>
      _isDark ? const Color(0xFF0D1117) : const Color(0xFFFFFFFF);
  Color get inputBorder =>
      _isDark ? const Color(0xFF30363D) : const Color(0xFF8C8C8C);
  Color get inputFocusBorder =>
      _isDark ? const Color(0xFF3B82F6) : const Color(0xFF1D4ED8);

  // Progress bar colors
  Color get progressBackground =>
      _isDark ? const Color(0xFF30363D) : const Color(0xFFE5E5E5);
  Color get progressFill =>
      _isDark ? const Color(0xFF3B82F6) : const Color(0xFF1D4ED8);
}
