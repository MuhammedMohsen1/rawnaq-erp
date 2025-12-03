import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          deviceToken: null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          log('🚩 UI: AuthBloc state changed to: ${state.runtimeType}');
          if (state is AuthAuthenticated) {
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
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo and Title
                      Container(
                        height: 80,
                        width: 80,
                        margin: const EdgeInsets.only(bottom: 32),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryLight,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.business,
                          size: 40,
                          color: AppColors.white,
                        ),
                      ),

                      Text(
                        'أهلاً بعودتك!',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'سجل دخولك إلى نظام إدارة المشاريع',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Email Field
                      CustomTextField(
                        label: 'البريد الإلكتروني',
                        hint: 'أدخل بريدك الإلكتروني',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textMuted,
                        ),
                        validator: Validators.validateEmail,
                      ),

                      const SizedBox(height: 24),

                      // Password Field
                      CustomTextField(
                        label: 'كلمة المرور',
                        hint: 'أدخل كلمة المرور',
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: AppColors.textMuted,
                        ),
                        validator: Validators.validatePasswordLogin,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _onLoginPressed();
                          }
                        },
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return CustomButton(
                            text: 'تسجيل الدخول',
                            onPressed: _onLoginPressed,
                            isLoading: state is AuthLoading,
                            width: double.infinity,
                            height: 56,
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Help Text
                      Text(
                        'تحتاج مساعدة؟ تواصل مع مدير النظام',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
