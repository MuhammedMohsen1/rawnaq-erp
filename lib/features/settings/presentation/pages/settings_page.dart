import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Settings page with language and app configuration
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate to login page after logout
          context.go(AppRoutes.login);
        } else if (state is AuthError) {
          // Show error message if logout fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.sidebarBackground,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('الإعدادات', style: AppTextStyles.pageTitle),
              const SizedBox(height: 8),
              Text(
                'تخصيص إعدادات التطبيق والحساب',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 32),

            // Language Section
            _buildSection(
              title: 'اللغة',
              icon: Icons.language,
              child: const _LanguageSelector(),
            ),

            const SizedBox(height: 24),

            // Theme Section (placeholder)
            _buildSection(
              title: 'المظهر',
              icon: Icons.palette_outlined,
              child: _buildSettingTile(
                title: 'الوضع الداكن',
                subtitle: 'مفعّل',
                trailing: Switch(
                  value: true,
                  onChanged: null, // Disabled for now
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notifications Section (placeholder)
            _buildSection(
              title: 'الإشعارات',
              icon: Icons.notifications_outlined,
              child: Column(
                children: [
                  _buildSettingTile(
                    title: 'إشعارات المهام',
                    subtitle: 'تلقي إشعارات عند تحديث المهام',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _buildSettingTile(
                    title: 'إشعارات المواعيد',
                    subtitle: 'تذكير قبل المواعيد',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSection(
              title: 'حول التطبيق',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  _buildSettingTile(
                    title: 'الإصدار',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _buildSettingTile(
                    title: 'رونق',
                    subtitle: 'نظام إدارة المشاريع للتصميم الداخلي',
                    onTap: null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Section with Sign Out
            _buildSection(
              title: 'الحساب',
              icon: Icons.account_circle_outlined,
              child: const _SignOutButton(),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.sectionTitle),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.tableCellBold),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Column(
      children: [
        _LanguageOption(
          title: 'العربية',
          subtitle: 'Arabic',
          isSelected: isArabic,
          onTap: () => localeProvider.setLocale(const Locale('ar')),
        ),
        const Divider(color: AppColors.divider, height: 1),
        _LanguageOption(
          title: 'English',
          subtitle: 'الإنجليزية',
          isSelected: !isArabic,
          onTap: () => localeProvider.setLocale(const Locale('en')),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Flag/Icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  title == 'العربية' ? 'ع' : 'En',
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.tableCellBold.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        
        return InkWell(
          onTap: isLoading
              ? null
              : () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: AppColors.cardBackground,
                      title: Text(
                        'تسجيل الخروج',
                        style: AppTextStyles.tableCellBold,
                      ),
                      content: Text(
                        'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                        style: AppTextStyles.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            'إلغاء',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            // Dispatch logout event
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                          child: Text(
                            'تسجيل الخروج',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تسجيل الخروج',
                        style: AppTextStyles.tableCellBold.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تسجيل الخروج من حسابك',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
