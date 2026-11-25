import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static final darkTheme = _theme(AppColors.dark);
  static final lightTheme = _theme(AppColors.light);
  static ThemeData _theme(AppColors colors) {
    final onAccent = colors.brightness == Brightness.dark
        ? AppColors.black
        : AppColors.white;
    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      canvasColor: colors.surface,
      disabledColor: colors.textDisabled,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: colors.brightness,
        primary: colors.primary,
        primaryContainer: colors.tableRowHover,
        onPrimaryContainer: colors.textPrimary,
        secondary: colors.secondary,
        secondaryContainer: colors.tableRowHover,
        onSecondaryContainer: colors.textPrimary,
        surface: colors.surface,
        error: colors.error,
        onPrimary: onAccent,
        onSecondary: onAccent,
        onSurface: colors.textPrimary,
        onError: onAccent,
        outline: colors.border,
        onSurfaceVariant: colors.textSecondary,
      ),
      splashColor: colors.hoverSurface,
      highlightColor: colors.hoverSurface,
      hoverColor: colors.hoverSurface,
      focusColor: colors.selectedSurface,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colors.sidebarBackground,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.buttonPrimary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.surfaceColor;
            }
            if (states.contains(WidgetState.hovered)) {
              return colors.buttonHover;
            }
            return colors.buttonPrimary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? colors.textDisabled
                : AppColors.white;
          }),
          overlayColor: WidgetStateProperty.all(colors.hoverSurface),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.inputFocusBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
        prefixIconColor: colors.textMuted,
        suffixIconColor: colors.textMuted,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        elevation: 0,
        shadowColor: colors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceColor,
        selectedColor: colors.selectedSurface,
        disabledColor: colors.darkGrey,
        labelStyle: TextStyle(color: colors.textPrimary, fontSize: 12),
        secondaryLabelStyle: TextStyle(
          color: colors.primaryLight,
          fontSize: 12,
        ),
        checkmarkColor: Colors.transparent,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: colors.border),
      ),

      // Match the selected surface used by chips.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? colors.selectedSurface
                : colors.surfaceColor;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? colors.primaryLight
                : colors.textSecondary;
          }),
          overlayColor: WidgetStateProperty.all(colors.hoverSurface),
          side: WidgetStateProperty.resolveWith((states) {
            return BorderSide(
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.border,
            );
          }),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colors.cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.cardBackground,
        modalBackgroundColor: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.sidebarBackground,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: colors.sidebarBackground,
        elevation: 0,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.buttonPrimary,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),

      // Data Table Theme
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(colors.tableHeader),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return colors.tableRowHover;
          }
          return colors.tableRowEven;
        }),
        headingTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
        dividerThickness: 1,
        horizontalMargin: 16,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: colors.textSecondary, size: 24),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: colors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: colors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: colors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: colors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: colors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: colors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: colors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: colors.textSecondary, fontSize: 16),
        bodyMedium: TextStyle(color: colors.textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: colors.textMuted, fontSize: 12),
        labelLarge: TextStyle(
          color: colors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: colors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Scrollbar Theme
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          colors.textMuted.withValues(alpha: 0.5),
        ),
        trackColor: WidgetStateProperty.all(colors.surfaceColor),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(8),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.progressBackground,
        circularTrackColor: colors.progressBackground,
      ),

      // Popup Menu Theme
      popupMenuTheme: PopupMenuThemeData(
        color: colors.cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.border),
        ),
        textStyle: TextStyle(color: colors.textPrimary, fontSize: 14),
      ),

      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(colors.cardBackground),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          side: WidgetStateProperty.all(BorderSide(color: colors.border)),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colors.cardBackground),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        textStyle: TextStyle(color: colors.textPrimary),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.selectedSurfaceStrong,
        selectionHandleColor: colors.primary,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surfaceColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.border),
        ),
        textStyle: TextStyle(color: colors.textPrimary, fontSize: 12),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceColor,
        contentTextStyle: TextStyle(color: colors.textPrimary, fontSize: 14),
        actionTextColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.textMuted,
        indicatorColor: colors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        textColor: colors.textPrimary,
        iconColor: colors.textSecondary,
        tileColor: Colors.transparent,
        selectedTileColor: colors.surfaceColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: 0.5);
          }
          return colors.border;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.secondary.withValues(alpha: 0.92);
          }
          if (states.contains(WidgetState.disabled)) {
            return colors.surfaceColor.withValues(alpha: 0.24);
          }
          return colors.surfaceColor.withValues(alpha: 0.22);
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.secondary.withValues(alpha: 0.16);
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.secondary.withValues(alpha: 0.10);
          }
          return Colors.transparent;
        }),
        side: BorderSide(
          color: colors.textMuted.withValues(alpha: 0.65),
          width: 1.4,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.textMuted;
        }),
      ),
    );
  }
}
