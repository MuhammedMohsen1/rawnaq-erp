import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._(this._colors);

  factory AppTextStyles.of(BuildContext context) =>
      AppTextStyles._(AppColors.of(context));

  final AppColors _colors;

  // Page titles
  TextStyle get pageTitle => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: _colors.textPrimary,
    height: 1.3,
  );

  // Section titles
  TextStyle get sectionTitle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    height: 1.4,
  );

  // Headings
  TextStyle get h1 => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: _colors.textPrimary,
    height: 1.2,
  );

  TextStyle get h2 => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: _colors.textPrimary,
    height: 1.2,
  );

  TextStyle get h3 => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    height: 1.3,
  );

  TextStyle get h4 => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    height: 1.3,
  );

  TextStyle get h5 => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    height: 1.4,
  );

  TextStyle get h6 => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    height: 1.4,
  );

  // Body text
  TextStyle get bodyLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: _colors.textSecondary,
    height: 1.5,
  );

  TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: _colors.textSecondary,
    height: 1.5,
  );

  TextStyle get bodySmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: _colors.textMuted,
    height: 1.5,
  );

  // Buttons
  TextStyle get buttonLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  TextStyle get buttonMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  TextStyle get buttonSmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  // Table styles
  TextStyle get tableHeader => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    height: 1.3,
  );

  TextStyle get tableCell => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: _colors.textSecondary,
    height: 1.4,
  );

  TextStyle get tableCellBold => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _colors.textPrimary,
    height: 1.4,
  );

  // Captions and labels
  TextStyle get caption => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: _colors.textMuted,
    height: 1.3,
  );

  TextStyle get label => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _colors.textSecondary,
    height: 1.3,
  );

  TextStyle get labelSmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _colors.textMuted,
    height: 1.3,
  );

  TextStyle get overline => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: _colors.textMuted,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Status badge styles
  TextStyle get statusBadge =>
      TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2);

  // Navigation styles
  TextStyle get navItem => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _colors.textSecondary,
    height: 1.3,
  );

  TextStyle get navItemActive => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    height: 1.3,
  );

  // Input styles
  TextStyle get inputText => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: _colors.textPrimary,
    height: 1.4,
  );

  TextStyle get inputHint => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: _colors.textMuted,
    height: 1.4,
  );

  TextStyle get inputLabel => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _colors.textSecondary,
    height: 1.3,
  );

  // Special styles
  TextStyle get error => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: _colors.error,
    height: 1.3,
  );

  TextStyle get success => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: _colors.success,
    height: 1.3,
  );

  TextStyle get warning => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: _colors.warning,
    height: 1.3,
  );

  TextStyle get link => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _colors.primary,
    height: 1.3,
    decoration: TextDecoration.underline,
  );

  // Stats/Numbers
  TextStyle get statNumber => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: _colors.textPrimary,
    height: 1.2,
  );

  TextStyle get statLabel => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _colors.textMuted,
    height: 1.3,
  );

  // Percentage/Progress
  TextStyle get percentage => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    height: 1.2,
  );
}
