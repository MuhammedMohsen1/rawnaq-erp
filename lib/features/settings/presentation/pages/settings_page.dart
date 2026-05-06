import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/datasources/settings_api_datasource.dart';

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SettingsHeader(),
                          const SizedBox(height: 24),

                          const _SettingsSection(
                            title: 'اللغة',
                            subtitle: 'اختيار لغة واجهة النظام',
                            icon: Icons.language,
                            child: _LanguageSelector(),
                          ),

                          const SizedBox(height: 16),

                          _SettingsSection(
                            title: 'المظهر',
                            subtitle: 'إعدادات شكل التطبيق',
                            icon: Icons.palette_outlined,
                            child: _SettingsTile(
                              title: 'الوضع الداكن',
                              subtitle: 'مفعّل حاليا',
                              leadingIcon: Icons.dark_mode_outlined,
                              trailing: Switch(value: true, onChanged: null),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _SettingsSection(
                            title: 'الإشعارات',
                            subtitle: 'إدارة تنبيهات المهام والمواعيد',
                            icon: Icons.notifications_outlined,
                            child: Column(
                              children: [
                                _SettingsTile(
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
                                _SettingsTile(
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
                                  _SettingsSection(
                                    title: 'ملاحظات عروض السعر الافتراضية',
                                    subtitle:
                                        'إدارة الملاحظات التي تظهر تلقائيا في كل عرض سعر جديد',
                                    icon: Icons.sticky_note_2_outlined,
                                    child: _PricingNotesEditor(),
                                  ),
                                  SizedBox(height: 16),
                                  _SettingsSection(
                                    title: 'بنود العقد الافتراضية',
                                    subtitle:
                                        'إدارة البنود التي تظهر تلقائيا عند تصدير عقود PDF',
                                    icon: Icons.description_outlined,
                                    child: _ContractTermsEditor(),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              );
                            },
                          ),

                          const _SettingsSection(
                            title: 'حول التطبيق',
                            subtitle: 'معلومات الإصدار والنظام',
                            icon: Icons.info_outline,
                            child: Column(
                              children: [
                                _SettingsTile(
                                  title: 'الإصدار',
                                  subtitle: '1.0.0',
                                  leadingIcon: Icons.verified_outlined,
                                ),
                                Divider(color: AppColors.divider, height: 1),
                                _SettingsTile(
                                  title: 'رونق',
                                  subtitle:
                                      'نظام إدارة المشاريع للتصميم الداخلي',
                                  leadingIcon: Icons.apartment_outlined,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          const _SettingsSection(
                            title: 'الحساب',
                            subtitle: 'إدارة جلسة المستخدم الحالية',
                            icon: Icons.account_circle_outlined,
                            child: _SignOutButton(),
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

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الإعدادات', style: AppTextStyles.pageTitle),
                const SizedBox(height: 6),
                Text(
                  'تخصيص إعدادات التطبيق والحساب وإعدادات العقود الافتراضية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.tableCellBold),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
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
          badge: 'ع',
          isSelected: isArabic,
          onTap: () => localeProvider.setLocale(const Locale('ar')),
        ),
        const Divider(color: AppColors.divider, height: 1),
        _LanguageOption(
          title: 'English',
          subtitle: 'الإنجليزية',
          badge: 'En',
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
  final String badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.06)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.14)
                      : AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.24)
                        : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    badge,
                    style: AppTextStyles.tableCellBold.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isSelected
                    ? Container(
                        key: const ValueKey('selected'),
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 15,
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey('not-selected'),
                        width: 25,
                        height: 25,
                      ),
              ),
            ],
          ),
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

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            backgroundColor: AppColors.cardBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              'تسجيل الخروج',
                              style: AppTextStyles.sectionTitle,
                            ),
                            content: Text(
                              'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            actionsPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: Text(
                                  'إلغاء',
                                  style: AppTextStyles.tableCellBold.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  context.read<AuthBloc>().add(
                                    LogoutRequested(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'تسجيل الخروج',
                                  style: AppTextStyles.tableCellBold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          'إنهاء الجلسة الحالية والعودة إلى صفحة الدخول',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
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
                      Icons.chevron_left,
                      color: Colors.red.withValues(alpha: 0.7),
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContractTermsEditor extends StatefulWidget {
  const _ContractTermsEditor();

  @override
  State<_ContractTermsEditor> createState() => _ContractTermsEditorState();
}

class _PricingNotesEditor extends StatefulWidget {
  const _PricingNotesEditor();

  @override
  State<_PricingNotesEditor> createState() => _PricingNotesEditorState();
}

class _PricingNotesEditorState extends State<_PricingNotesEditor> {
  final SettingsApiDataSource _settingsApi = SettingsApiDataSource();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final notes = await _settingsApi.getDefaultPricingNotes();
      if (!mounted) return;

      setState(() {
        _notesController.text = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل ملاحظات عرض السعر';
      });
    }
  }

  Future<void> _saveNotes() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _settingsApi.updateDefaultPricingNotes(
        _notesController.text.trim(),
      );
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _successMessage = 'تم حفظ ملاحظات عرض السعر بنجاح';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ ملاحظات عرض السعر بنجاح',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _errorMessage = 'فشل حفظ ملاحظات عرض السعر: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _ContractTermsLoading();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'كل سطر سيظهر كملاحظة منفصلة في PDF عرض السعر. يمكن تعديل هذه الملاحظات لاحقا داخل كل عرض سعر بدون تغيير الافتراضي.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notesController,
            minLines: 4,
            maxLines: 8,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'ملاحظات عرض السعر الافتراضية',
              hintText: 'اكتب كل ملاحظة في سطر منفصل',
              prefixIcon: const Icon(
                Icons.notes_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
              labelStyle: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
              hintStyle: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            _ContractTermsMessage(
              message: _errorMessage!,
              type: _ContractTermsMessageType.error,
            ),
          ],
          if (_successMessage != null) ...[
            const SizedBox(height: 10),
            _ContractTermsMessage(
              message: _successMessage!,
              type: _ContractTermsMessageType.success,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _saveNotes,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 19),
              label: Text(
                _isSaving ? 'جار الحفظ...' : 'حفظ الملاحظات الافتراضية',
                style: AppTextStyles.tableCellBold.copyWith(
                  color: AppColors.white,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.28),
                ),
                textStyle: AppTextStyles.tableCellBold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractTermsEditorState extends State<_ContractTermsEditor> {
  final SettingsApiDataSource _settingsApi = SettingsApiDataSource();

  final List<_ContractTermControllers> _terms = [];

  bool _isLoading = true;
  bool _isSaving = false;
  int? _expandedIndex = 0;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final terms = await _settingsApi.getDefaultContractTerms();

      if (!mounted) return;

      final nextTerms = terms.map<_ContractTermControllers>((term) {
        return _ContractTermControllers(
          title: term['title'] ?? '',
          description: term['description'] ?? '',
        );
      }).toList();

      if (nextTerms.isEmpty) {
        nextTerms.add(_ContractTermControllers());
      }

      _disposeTerms();

      setState(() {
        _terms
          ..clear()
          ..addAll(nextTerms);
        _expandedIndex = 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل بنود العقد';
      });
    }
  }

  void _addTerm() {
    setState(() {
      _terms.add(_ContractTermControllers());
      _expandedIndex = _terms.length - 1;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  void _removeTerm(int index) {
    if (_terms.length <= 1) return;

    setState(() {
      _terms[index].dispose();
      _terms.removeAt(index);

      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else if (_expandedIndex != null && _expandedIndex! > index) {
        _expandedIndex = _expandedIndex! - 1;
      }

      _errorMessage = null;
      _successMessage = null;
    });
  }

  void _toggleTerm(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  String? _validateTerms() {
    for (var i = 0; i < _terms.length; i++) {
      final title = _terms[i].title.text.trim();
      final description = _terms[i].description.text.trim();

      if (title.isEmpty) {
        _expandedIndex = i;
        return 'جميع البنود يجب أن تحتوي على عنوان';
      }

      if (description.isEmpty) {
        _expandedIndex = i;
        return 'جميع البنود يجب أن تحتوي على وصف';
      }
    }

    return null;
  }

  Future<void> _saveTerms() async {
    final validationMessage = _validateTerms();

    if (validationMessage != null) {
      setState(() {
        _errorMessage = validationMessage;
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final termsToSave = _terms.map((term) {
        return {
          'title': term.title.text.trim(),
          'description': term.description.text.trim(),
        };
      }).toList();

      await _settingsApi.updateDefaultContractTerms(termsToSave);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _successMessage = 'تم حفظ بنود العقد بنجاح';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ بنود العقد بنجاح',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;

        setState(() {
          _successMessage = null;
        });
      });
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'فشل حفظ بنود العقد';

      if (e is ServerException) {
        errorMessage = 'فشل حفظ بنود العقد: ${e.message}';
      } else if (e is ValidationException) {
        errorMessage = 'فشل حفظ بنود العقد: ${e.message}';
      } else {
        errorMessage = 'فشل حفظ بنود العقد: ${e.toString()}';
      }

      setState(() {
        _isSaving = false;
        _errorMessage = errorMessage;
      });
    }
  }

  void _disposeTerms() {
    for (final term in _terms) {
      term.dispose();
    }
  }

  @override
  void dispose() {
    _disposeTerms();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _ContractTermsLoading();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'يمكنك تعديل بنود العقد الافتراضية التي ستظهر عند تصدير عقود PDF. اضغط على أي بند لفتحه وتعديله.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),

          _ContractTermsToolbar(count: _terms.length, onAdd: _addTerm),

          const SizedBox(height: 12),

          ...List.generate(_terms.length, (index) {
            final term = _terms[index];

            return _ContractTermAccordionCard(
              index: index,
              isExpanded: _expandedIndex == index,
              canDelete: _terms.length > 1,
              titleController: term.title,
              descriptionController: term.description,
              onToggle: () => _toggleTerm(index),
              onDelete: () => _removeTerm(index),
              fieldDecoration: _fieldDecoration,
            );
          }),

          if (_errorMessage != null) ...[
            const SizedBox(height: 4),
            _ContractTermsMessage(
              message: _errorMessage!,
              type: _ContractTermsMessageType.error,
            ),
          ],

          if (_successMessage != null) ...[
            const SizedBox(height: 4),
            _ContractTermsMessage(
              message: _successMessage!,
              type: _ContractTermsMessageType.success,
            ),
          ],

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _saveTerms,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 19),
              label: Text(
                _isSaving ? 'جار الحفظ...' : 'حفظ جميع البنود',
                style: AppTextStyles.tableCellBold.copyWith(
                  color: AppColors.white,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.28),
                ),
                textStyle: AppTextStyles.tableCellBold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractTermControllers {
  final TextEditingController title;
  final TextEditingController description;

  _ContractTermControllers({String title = '', String description = ''})
    : title = TextEditingController(text: title),
      description = TextEditingController(text: description);

  void dispose() {
    title.dispose();
    description.dispose();
  }
}

class _ContractTermsLoading extends StatelessWidget {
  const _ContractTermsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _ContractTermsToolbar extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;

  const _ContractTermsToolbar({required this.count, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 420;

        final countChip = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.format_list_numbered_rtl,
                color: AppColors.primary,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(
                'عدد البنود: $count',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

        final addButton = OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('إضافة بند'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.28)),
            textStyle: AppTextStyles.tableCellBold,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (isTight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [countChip, const SizedBox(height: 8), addButton],
          );
        }

        return Row(children: [countChip, const Spacer(), addButton]);
      },
    );
  }
}

class _ContractTermAccordionCard extends StatelessWidget {
  final int index;
  final bool isExpanded;
  final bool canDelete;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final InputDecoration Function({
    required String label,
    required String hint,
    required IconData icon,
  })
  fieldDecoration;

  const _ContractTermAccordionCard({
    required this.index,
    required this.isExpanded,
    required this.canDelete,
    required this.titleController,
    required this.descriptionController,
    required this.onToggle,
    required this.onDelete,
    required this.fieldDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final description = descriptionController.text.trim();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isExpanded
            ? AppColors.primary.withValues(alpha: 0.035)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.32)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.tableCellBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: titleController,
                        builder: (context, value, _) {
                          final currentTitle = value.text.trim();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTitle.isEmpty
                                    ? 'بند ${index + 1}'
                                    : currentTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.tableCellBold.copyWith(
                                  color: currentTitle.isEmpty
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description.isEmpty
                                    ? 'اضغط لفتح وتعديل بيانات البند'
                                    : description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (canDelete)
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'حذف البند',
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 21,
                          color: Colors.red,
                        ),
                      ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 14),

                  TextField(
                    controller: titleController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    textInputAction: TextInputAction.next,
                    style: AppTextStyles.tableCellBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: fieldDecoration(
                      label: 'العنوان',
                      hint: 'مثال: أولا: التمهيد',
                      icon: Icons.title,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: descriptionController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    minLines: 4,
                    maxLines: 7,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: fieldDecoration(
                      label: 'الوصف',
                      hint: 'أدخل نص البند هنا...',
                      icon: Icons.description_outlined,
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeOut,
          ),
        ],
      ),
    );
  }
}

enum _ContractTermsMessageType { error, success }

class _ContractTermsMessage extends StatelessWidget {
  final String message;
  final _ContractTermsMessageType type;

  const _ContractTermsMessage({required this.message, required this.type});

  bool get _isError => type == _ContractTermsMessageType.error;

  @override
  Widget build(BuildContext context) {
    final color = _isError ? Colors.red : Colors.green;
    final icon = _isError ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
