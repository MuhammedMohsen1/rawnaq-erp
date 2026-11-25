import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPageContent extends StatefulWidget {
  const LoginPageContent({super.key});

  @override
  State<LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<LoginPageContent> {
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const _LoginBrand(),
                const SizedBox(height: 48),
                const _LoginWelcome(),
                const SizedBox(height: 48),
                CustomTextField(
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.of(context).textMuted,
                  ),
                  validator: Validators.validateEmail,
                  fillColor: AppColors.of(context).inputBackground,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icon(
                    Icons.lock_outlined,
                    color: AppColors.of(context).textMuted,
                  ),
                  validator: Validators.validatePasswordLogin,
                  fillColor: AppColors.of(context).inputBackground,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _onLoginPressed();
                    }
                  },
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'تسجيل الدخول',
                      onPressed: _onLoginPressed,
                      isLoading: state is AuthLoading,
                      width: double.infinity,
                      height: 56,
                      backgroundColor: AppColors.of(context).statusActive,
                    );
                  },
                ),
                const SizedBox(height: 24),
                const _LoginHelpText(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.of(context).statusActive,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.of(
                  context,
                ).statusActive.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.construction,
            size: 50,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Rawnaq',
          style: AppTextStyles.of(context).h1.copyWith(
            color: AppColors.of(context).textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'نظام إدارة المشاريع',
          style: AppTextStyles.of(context).bodyMedium.copyWith(
            color: AppColors.of(context).textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _LoginWelcome extends StatelessWidget {
  const _LoginWelcome();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'أهلاً بعودتك!',
          style: AppTextStyles.of(context).h2.copyWith(
            color: AppColors.of(context).textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'سجل دخولك للوصول إلى لوحة التحكم',
          style: AppTextStyles.of(
            context,
          ).bodyMedium.copyWith(color: AppColors.of(context).textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginHelpText extends StatelessWidget {
  const _LoginHelpText();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            size: 18,
            color: AppColors.of(context).textMuted,
          ),
          const SizedBox(width: 8),
          Text(
            'تحتاج مساعدة؟ تواصل مع مدير النظام',
            style: AppTextStyles.of(
              context,
            ).bodySmall.copyWith(color: AppColors.of(context).textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
