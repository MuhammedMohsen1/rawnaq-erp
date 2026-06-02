import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/login_page_content.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthState? _previousState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          log('🚩 UI: AuthBloc state changed to: ${state.runtimeType}');

          if (state is AuthAuthenticated && _previousState is AuthLoading) {
            log('🚩 UI: تم تسجيل الدخول بنجاح');
            context.go(AppRoutes.dashboard);
          } else if (state is AuthError) {
            log('🚩 UI: AuthError received: ${state.message}');
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 4),
              ),
            );
          }

          _previousState = state;
        },
        child: const SafeArea(child: LoginPageContent()),
      ),
    );
  }
}
