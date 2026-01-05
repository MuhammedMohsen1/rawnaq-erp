import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/providers/locale_provider.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'l10n/app_localizations.dart';

// Rawnaq - Project Management for Interior Design Teams
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy for web to remove # from URLs
  usePathUrlStrategy();

  // Setup dependency injection
  await setupDI();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadLocale()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => getIt<AuthBloc>()..add(AuthStatusChecked()),
            ),
          ],
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) {
              // Only listen to state changes, not initial state
              return previous != current;
            },
            listener: (context, state) {
              final router = AppRouter.router;
              
              // If user becomes authenticated, ensure we're not on auth pages
              if (state is AuthAuthenticated) {
                // Small delay to ensure router is ready
                Future.microtask(() {
                  final currentLocation = router.routerDelegate.currentConfiguration.uri.toString();
                  if (currentLocation == AppRoutes.login || 
                      currentLocation == AppRoutes.resetPassword) {
                    router.go(AppRoutes.dashboard);
                  }
                });
              }
              // If user becomes unauthenticated, navigate to login
              else if (state is AuthUnauthenticated) {
                Future.microtask(() {
                  final currentLocation = router.routerDelegate.currentConfiguration.uri.toString();
                  if (currentLocation != AppRoutes.login && 
                      currentLocation != AppRoutes.resetPassword) {
                    router.go(AppRoutes.login);
                  }
                });
              }
            },
            child: MaterialApp.router(
              title: 'Rawnaq',
              locale: localeProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('ar')],
              theme: AppTheme.darkTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.dark,
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                return Directionality(
                  textDirection: localeProvider.textDirection,
                  child: child!,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
