import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/datasources/settings_api_datasource.dart';
import '../../../../core/error/exceptions.dart';

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

              // Contract Terms Section (Admin/Manager only)
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is! AuthAuthenticated) {
                    return const SizedBox.shrink();
                  }

                  final user = state.user;
                  final isAdminOrManager = user.isAdmin || user.isManager;

                  if (!isAdminOrManager) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      _buildSection(
                        title: 'بنود العقد الافتراضية',
                        icon: Icons.description,
                        child: const _ContractTermsEditor(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

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
                  Icon(Icons.logout, color: Colors.red, size: 20),
              ],
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

class _ContractTermsEditorState extends State<_ContractTermsEditor> {
  final SettingsApiDataSource _settingsApi = SettingsApiDataSource();
  List<Map<String, TextEditingController>> _terms = [];
  bool _isLoading = true;
  bool _isSaving = false;
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
    });

    try {
      final terms = await _settingsApi.getDefaultContractTerms();
      if (mounted) {
        setState(() {
          _terms = terms.map((term) {
            return {
              'title': TextEditingController(text: term['title'] ?? ''),
              'description': TextEditingController(
                text: term['description'] ?? '',
              ),
            };
          }).toList();

          // If no terms, add one empty term
          if (_terms.isEmpty) {
            _terms.add({
              'title': TextEditingController(),
              'description': TextEditingController(),
            });
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل تحميل بنود العقد';
        });
      }
    }
  }

  void _addTerm() {
    setState(() {
      _terms.add({
        'title': TextEditingController(),
        'description': TextEditingController(),
      });
    });
  }

  void _removeTerm(int index) {
    if (_terms.length > 1) {
      setState(() {
        _terms[index]['title']?.dispose();
        _terms[index]['description']?.dispose();
        _terms.removeAt(index);
      });
    }
  }

  Future<void> _saveTerms() async {
    // Validate all terms have title and description
    for (var i = 0; i < _terms.length; i++) {
      final title = _terms[i]['title']?.text.trim() ?? '';
      final description = _terms[i]['description']?.text.trim() ?? '';

      if (title.isEmpty) {
        setState(() {
          _errorMessage = 'جميع البنود يجب أن تحتوي على عنوان';
        });
        return;
      }

      if (description.isEmpty) {
        setState(() {
          _errorMessage = 'جميع البنود يجب أن تحتوي على وصف';
        });
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final termsToSave = _terms.map((term) {
        return {
          'title': term['title']?.text.trim() ?? '',
          'description': term['description']?.text.trim() ?? '',
        };
      }).toList();

      await _settingsApi.updateDefaultContractTerms(termsToSave);

      if (mounted) {
        // Reload terms to ensure we have the latest data
        await _loadTerms();

        setState(() {
          _isSaving = false;
          _successMessage = 'تم حفظ بنود العقد بنجاح';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ بنود العقد بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _successMessage = null;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
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
  }

  @override
  void dispose() {
    for (var term in _terms) {
      term['title']?.dispose();
      term['description']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'يمكنك تعديل بنود العقد الافتراضية التي ستظهر عند تصدير عقود PDF',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add term button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'عدد البنود: ${_terms.length}',
                      style: AppTextStyles.caption,
                    ),
                    TextButton.icon(
                      onPressed: _addTerm,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة بند'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Terms list
                ...List.generate(_terms.length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'بند ${index + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (_terms.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 22,
                                ),
                                onPressed: () => _removeTerm(index),
                                tooltip: 'حذف البند',
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _terms[index]['title'],
                          decoration: InputDecoration(
                            labelText: 'العنوان',
                            hintText: 'مثال: أولا: التمهيد',
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _terms[index]['description'],
                          maxLines: 6,
                          minLines: 4,
                          decoration: InputDecoration(
                            labelText: 'الوصف',
                            hintText: 'أدخل نص البند هنا...',
                            prefixIcon: const Icon(Icons.description),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: const TextStyle(fontSize: 13),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  );
                }),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_successMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveTerms,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('حفظ جميع البنود'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
