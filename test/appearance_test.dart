import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rawnaq/core/constants/app_colors.dart';
import 'package:rawnaq/core/providers/appearance_provider.dart';
import 'package:rawnaq/core/theme/app_theme.dart';
import 'package:rawnaq/core/widgets/app_toast.dart';
import 'package:rawnaq/features/settings/presentation/widgets/appearance_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'system appearance reacts to the OS and Settings persists a choice',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final appearance = AppearanceProvider(preferences);
      addTearDown(appearance.dispose);
      final dispatcher = tester.binding.platformDispatcher;
      addTearDown(dispatcher.clearPlatformBrightnessTestValue);

      dispatcher.platformBrightnessTestValue = Brightness.light;
      expect(appearance.mode, ThemeMode.system);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appearance,
          child: Consumer<AppearanceProvider>(
            builder: (context, appearance, _) => MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: appearance.mode,
              home: const Scaffold(body: AppearanceSelector()),
            ),
          ),
        ),
      );

      Brightness brightness() =>
          Theme.of(tester.element(find.byType(AppearanceSelector))).brightness;

      expect(brightness(), Brightness.light);
      dispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.dark);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.light);
      final restored = AppearanceProvider(preferences);
      addTearDown(restored.dispose);
      expect(restored.mode, ThemeMode.light);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      dispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.dark);

      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.light);
    },
  );

  test('light surfaces and foregrounds have readable contrast', () {
    final palette = AppColors.light;
    for (final surface in [
      palette.scaffoldBackground,
      palette.sidebarBackground,
      palette.cardBackground,
      palette.surfaceColor,
      palette.inputBackground,
      palette.tableHeader,
      palette.tableRowOdd,
      palette.tableRowHover,
    ]) {
      expect(surface.computeLuminance(), greaterThan(0.75));
      for (final foreground in [
        palette.textPrimary,
        palette.textSecondary,
        palette.textMuted,
      ]) {
        expect(
          (surface.computeLuminance() + 0.05) /
              (foreground.computeLuminance() + 0.05),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });

  for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
    testWidgets('success and exception toasts in ${theme.brightness.name}', (
      tester,
    ) async {
      final messenger = GlobalKey<ScaffoldMessengerState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          scaffoldMessengerKey: messenger,
          home: const Scaffold(body: SizedBox()),
        ),
      );

      for (final (tone, icon, message) in [
        (ToastTone.success, Icons.check_circle_outline, 'Saved'),
        (ToastTone.error, Icons.error_outline, 'Save failed'),
      ]) {
        messenger.currentState!.showSnackBar(
          AppToast.build(tone: tone, content: Text(message)),
        );
        await tester.pumpAndSettle();

        final bar = tester.widget<SnackBar>(find.byType(SnackBar));
        final background = bar.backgroundColor!;
        final foreground = tester.widget<Icon>(find.byIcon(icon)).color!;
        if (tone == ToastTone.success) {
          expect(background.g, greaterThan(background.r));
        } else {
          expect(background.r, greaterThan(background.g));
        }
        expect(
          (background.computeLuminance() + 0.05) /
              (foreground.computeLuminance() + 0.05),
          greaterThan(4.5),
        );
        expect(bar.behavior, SnackBarBehavior.floating);
        expect(find.text(message), findsOneWidget);

        messenger.currentState!.removeCurrentSnackBar();
        await tester.pumpAndSettle();
      }
    });
  }
}
