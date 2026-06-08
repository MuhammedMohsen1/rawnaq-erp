import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/contract_terms_widgets.dart';
import '../widgets/language_selector.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_notes_editor.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/sign_out_button.dart';

/// Settings page with language and app configuration
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(AppRoutes.login);
          } else if (state is AuthError) {
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
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 700;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 24,
                    vertical: isCompact ? 16 : 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SettingsHeader(),
                          const SizedBox(height: 24),

                          const SettingsSection(
                            title: 'اللغة',
                            subtitle: 'اختيار لغة واجهة النظام',
                            icon: Icons.language,
                            child: LanguageSelector(),
                          ),

                          const SizedBox(height: 16),

                          SettingsSection(
                            title: 'المظهر',
                            subtitle: 'إعدادات شكل التطبيق',
                            icon: Icons.palette_outlined,
                            child: SettingsTile(
                              title: 'الوضع الداكن',
                              subtitle: 'مفعّل حاليا',
                              leadingIcon: Icons.dark_mode_outlined,
                              trailing: Switch(value: true, onChanged: null),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SettingsSection(
                            title: 'الإشعارات',
                            subtitle: 'إدارة تنبيهات المهام والمواعيد',
                            icon: Icons.notifications_outlined,
                            child: Column(
                              children: [
                                SettingsTile(
                                  title: 'إشعارات المهام',
                                  subtitle: 'تلقي إشعارات عند تحديث المهام',
                                  leadingIcon: Icons.task_alt_outlined,
                                  trailing: Switch(
                                    value: true,
                                    onChanged: (value) {},
                                  ),
                                ),
                                const Divider(
                                  color: AppColors.divider,
                                  height: 1,
                                ),
                                SettingsTile(
                                  title: 'إشعارات المواعيد',
                                  subtitle: 'تذكير قبل المواعيد',
                                  leadingIcon: Icons.event_available_outlined,
                                  trailing: Switch(
                                    value: true,
                                    onChanged: (value) {},
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is! AuthAuthenticated) {
                                return const SizedBox.shrink();
                              }

                              final user = state.user;
                              final isAdminOrManager =
                                  user.isAdmin || user.isManager;

                              if (!isAdminOrManager) {
                                return const SizedBox.shrink();
                              }

                              return const Column(
                                children: [
                                  SettingsSection(
                                    title: 'ملاحظات عروض السعر الافتراضية',
                                    subtitle:
                                        'إدارة الملاحظات التي تظهر تلقائيا في كل عرض سعر جديد',
                                    icon: Icons.sticky_note_2_outlined,
                                    child: PricingNotesEditor(),
                                  ),
                                  SizedBox(height: 16),
                                  SettingsSection(
                                    title: 'بنود العقد الافتراضية',
                                    subtitle:
                                        'إدارة البنود التي تظهر تلقائيا عند تصدير عقود PDF',
                                    icon: Icons.description_outlined,
                                    child: ContractTermsEditor(),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              );
                            },
                          ),

                          const SettingsSection(
                            title: 'حول التطبيق',
                            subtitle: 'معلومات الإصدار والنظام',
                            icon: Icons.info_outline,
                            child: Column(
                              children: [
                                SettingsTile(
                                  title: 'الإصدار',
                                  subtitle: '1.0.0',
                                  leadingIcon: Icons.verified_outlined,
                                ),
                                Divider(color: AppColors.divider, height: 1),
                                SettingsTile(
                                  title: 'رونق',
                                  subtitle:
                                      'نظام إدارة المشاريع للتصميم الداخلي',
                                  leadingIcon: Icons.apartment_outlined,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          const SettingsSection(
                            title: 'الحساب',
                            subtitle: 'إدارة جلسة المستخدم الحالية',
                            icon: Icons.account_circle_outlined,
                            child: SignOutButton(),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
