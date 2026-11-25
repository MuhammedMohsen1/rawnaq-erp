import 'package:rawnaq/core/widgets/app_toast.dart';
import 'package:rawnaq/core/utils/arabic_number_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/role_utils.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/admin_users_cubit.dart';
import '../cubit/admin_users_state.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated ||
            !RoleUtils.canManageUsers(authState.user)) {
          return const _AccessDeniedView();
        }

        return BlocProvider(
          create: (_) => AdminUsersCubit()..loadUsers(),
          child: const Directionality(
            textDirection: TextDirection.rtl,
            child: _AdminUsersView(),
          ),
        );
      },
    );
  }
}

class _AdminUsersView extends StatelessWidget {
  const _AdminUsersView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUsersCubit, AdminUsersState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.successMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context).showSnackBar(
          AppToast.build(
            tone: state.errorMessage == null
                ? ToastTone.success
                : ToastTone.error,
            duration: const Duration(seconds: 2),
            content: Text(
              ArabicNumberTransformer.transform(message),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      },
      builder: (context, state) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _Toolbar(state: state),
                  const SizedBox(height: 16),
                  Expanded(child: _UsersBody(state: state)),
                ],
              ),
            ),
            if (state.isSaving)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.18),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  final AdminUsersState state;

  const _Toolbar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            inputFormatters: const [ArabicNumberInputFormatter()],
            onChanged: context.read<AdminUsersCubit>().updateSearch,
            style: AppTextStyles.of(
              context,
            ).bodyMedium.copyWith(color: AppColors.of(context).textPrimary),
            decoration: _inputDecoration(
              context,
              hintText: 'بحث بالاسم أو البريد أو الهاتف',
              prefixIcon: Icons.search,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 180,
          child: _FilterDropdown(
            value: state.roleFilter,
            items: const {
              'all': 'كل الأدوار',
              AppConstants.adminRole: 'مدير نظام',
              AppConstants.managerRole: 'مدير',
              AppConstants.seniorEngineerRole: 'مهندس أول',
              AppConstants.juniorEngineerRole: 'مهندس',
              AppConstants.siteEngineerRole: 'مهندس موقع',
              'designer': 'مصمم',
            },
            onChanged: context.read<AdminUsersCubit>().updateRoleFilter,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 160,
          child: _FilterDropdown(
            value: state.statusFilter,
            items: const {
              'all': 'كل الحالات',
              'ACTIVE': 'نشط',
              'SUSPENDED': 'موقوف',
            },
            onChanged: context.read<AdminUsersCubit>().updateStatusFilter,
          ),
        ),
        const SizedBox(width: 12),
        _ToolbarIconButton(
          tooltip: 'تحديث',
          icon: Icons.refresh,
          onPressed: state.isLoading
              ? null
              : context.read<AdminUsersCubit>().loadUsers,
        ),
        const SizedBox(width: 8),
        _ToolbarTextButton(
          onPressed: state.isSaving
              ? null
              : () => _showUserDialog(context: context),
          icon: const Icon(Icons.person_add_alt_1, size: 18),
          label: 'مستخدم جديد',
        ),
      ],
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 44,
        height: 44,
        child: OutlinedButton(
          onPressed: onPressed,
          style: _toolbarButtonStyle(
            context,
            padding: EdgeInsets.zero,
            disabledOpacity: 0.45,
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _ToolbarTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;

  const _ToolbarTextButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: _toolbarButtonStyle(
          context,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          disabledOpacity: 0.45,
        ),
        icon: icon,
        label: Text(
          ArabicNumberTransformer.transform(label),
          style: AppTextStyles.of(
            context,
          ).bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.of(context).surfaceColor,
      iconEnabledColor: AppColors.of(context).textSecondary,
      style: AppTextStyles.of(
        context,
      ).bodyMedium.copyWith(color: AppColors.of(context).textPrimary),
      decoration: _inputDecoration(context),
      items: items.entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(ArabicNumberTransformer.transform(entry.value)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _UsersBody extends StatelessWidget {
  final AdminUsersState state;

  const _UsersBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AdminUsersFailure && state.users.isEmpty) {
      return _EmptyState(
        icon: Icons.error_outline,
        title: 'تعذر تحميل المستخدمين',
        subtitle: state.errorMessage ?? 'حدث خطأ غير متوقع',
        action: TextButton.icon(
          onPressed: context.read<AdminUsersCubit>().loadUsers,
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة المحاولة'),
        ),
      );
    }

    final users = state.filteredUsers;
    if (users.isEmpty) {
      return const _EmptyState(
        icon: Icons.manage_accounts_outlined,
        title: 'لا توجد نتائج',
        subtitle: 'غيّر البحث أو الفلاتر لعرض المستخدمين',
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.of(context).cardBackground,
        border: Border.all(color: AppColors.of(context).border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _TableHeader(total: users.length),
          Divider(color: AppColors.of(context).divider, height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.of(context).divider, height: 1),
              itemBuilder: (context, index) => _UserRow(user: users[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final int total;

  const _TableHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.of(context).tableHeader,
      child: Row(
        children: [
          Text(
            ArabicNumberTransformer.transform('المستخدمون ($total)'),
            style: AppTextStyles.of(context).bodyMedium.copyWith(
              color: AppColors.of(context).textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _HeaderLabel(width: 140, text: 'الدور'),
          _HeaderLabel(width: 110, text: 'الحالة'),
          _HeaderLabel(width: 140, text: 'آخر دخول'),
          const SizedBox(width: 132),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final double width;
  final String text;

  const _HeaderLabel({required this.width, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        ArabicNumberTransformer.transform(text),
        style: AppTextStyles.of(
          context,
        ).caption.copyWith(color: AppColors.of(context).textMuted),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final User user;

  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.of(context).surfaceColor,
            backgroundImage: user.avatar == null
                ? null
                : NetworkImage(user.avatar!),
            child: user.avatar == null
                ? Text(
                    ArabicNumberTransformer.transform(
                      user.name.isEmpty ? '?' : user.name.characters.first,
                    ),
                    style: AppTextStyles.of(context).bodyMedium.copyWith(
                      color: AppColors.of(context).textPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ArabicNumberTransformer.transform(user.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(context).bodyMedium.copyWith(
                    color: AppColors.of(context).textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ArabicNumberTransformer.transform(
                    [
                      user.email,
                      if (user.phone != null && user.phone!.isNotEmpty)
                        user.phone!,
                    ].join('  |  '),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(context).caption.copyWith(
                    color: AppColors.of(context).textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _RoleBadge(user: user),
          _StatusBadge(isActive: user.isActive),
          SizedBox(
            width: 140,
            child: Text(
              ArabicNumberTransformer.transform(
                user.lastLoginAt == null
                    ? 'لم يسجل'
                    : DateHelper.formatDate(user.lastLoginAt!),
              ),
              style: AppTextStyles.of(
                context,
              ).caption.copyWith(color: AppColors.of(context).textSecondary),
            ),
          ),
          SizedBox(
            width: 132,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'تعديل',
                  onPressed: () =>
                      _showUserDialog(context: context, user: user),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
                PopupMenuButton<String>(
                  tooltip: 'إجراءات',
                  color: AppColors.of(context).surfaceColor,
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) => _handleAction(context, user, value),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: user.isActive ? 'suspend' : 'activate',
                      child: Text(
                        ArabicNumberTransformer.transform(
                          user.isActive ? 'إيقاف الحساب' : 'تنشيط الحساب',
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('حذف المستخدم'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    User user,
    String action,
  ) async {
    final cubit = context.read<AdminUsersCubit>();
    if (action == 'activate') {
      await cubit.updateUserStatus(user, 'ACTIVE');
      return;
    }
    if (action == 'suspend') {
      await cubit.updateUserStatus(user, 'SUSPENDED');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.of(context).cardBackground,
        title: const Text('حذف المستخدم'),
        content: Text(
          ArabicNumberTransformer.transform(
            'هل تريد حذف ${user.name}؟ سيتم الحذف بشكل ناعم.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await cubit.deleteUser(user);
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final User user;

  const _RoleBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Align(
        alignment: Alignment.centerRight,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: user.effectiveRoles
              .map(
                (role) => _Badge(
                  text: _roleLabel(role),
                  color: role == AppConstants.adminRole
                      ? AppColors.of(context).info
                      : AppColors.of(context).primaryDark,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Align(
        alignment: Alignment.centerRight,
        child: _Badge(
          text: isActive ? 'نشط' : 'موقوف',
          color: isActive
              ? AppColors.of(context).success
              : AppColors.of(context).warning,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        ArabicNumberTransformer.transform(text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.of(context).caption.copyWith(color: color),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.of(context).textMuted),
          const SizedBox(height: 12),
          Text(
            ArabicNumberTransformer.transform(title),
            style: AppTextStyles.of(
              context,
            ).h6.copyWith(color: AppColors.of(context).textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            ArabicNumberTransformer.transform(subtitle),
            style: AppTextStyles.of(
              context,
            ).bodySmall.copyWith(color: AppColors.of(context).textSecondary),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

class _AccessDeniedView extends StatelessWidget {
  const _AccessDeniedView();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: _EmptyState(
        icon: Icons.lock_outline,
        title: 'غير مصرح',
        subtitle: 'هذه الصفحة متاحة لمدير النظام فقط',
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final User? user;

  const _UserFormDialog({this.user});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late Set<String> _roles;
  late String _accountStatus;
  late Set<String> _adminSubRoles;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _passwordController = TextEditingController();
    _roles = {
      ...(user?.roles ?? [AppConstants.siteEngineerRole]),
    };
    if (_roles.isEmpty) _roles.add(AppConstants.siteEngineerRole);
    _accountStatus = user?.isActive ?? true ? 'ACTIVE' : 'SUSPENDED';
    _adminSubRoles = {...?user?.adminSubRoles};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.of(context).cardBackground,
        title: Text(
          ArabicNumberTransformer.transform(
            _isEditing ? 'تعديل مستخدم' : 'إضافة مستخدم',
          ),
        ),
        content: SizedBox(
          width: 560,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    inputFormatters: const [ArabicNumberInputFormatter()],
                    controller: _nameController,
                    decoration: _inputDecoration(context, hintText: 'الاسم'),
                    validator: (value) =>
                        value == null || value.trim().length < 2
                        ? 'أدخل اسم المستخدم'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    inputFormatters: const [ArabicNumberInputFormatter()],
                    controller: _emailController,
                    enabled: !_isEditing,
                    decoration: _inputDecoration(
                      context,
                      hintText: 'البريد الإلكتروني',
                    ),
                    validator: (value) {
                      if (_isEditing) return null;
                      final email = value?.trim() ?? '';
                      return email.contains('@') ? null : 'أدخل بريد صحيح';
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    inputFormatters: const [ArabicNumberInputFormatter()],
                    controller: _phoneController,
                    decoration: _inputDecoration(
                      context,
                      hintText: 'الهاتف اختياري',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    inputFormatters: const [ArabicNumberInputFormatter()],
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration(
                      context,
                      hintText: _isEditing
                          ? 'كلمة مرور جديدة اختياري'
                          : 'كلمة المرور',
                    ),
                    validator: (value) {
                      final password = value ?? '';
                      if (_isEditing && password.isEmpty) return null;
                      return password.length >= AppConstants.minPasswordLength
                          ? null
                          : 'كلمة المرور 8 أحرف على الأقل';
                    },
                  ),
                  const SizedBox(height: 12),
                  _RolesSelector(
                    selected: _roles,
                    onChanged: (selected) => setState(() => _roles = selected),
                  ),
                  const SizedBox(height: 12),
                  _DialogDropdown(
                    value: _accountStatus,
                    label: 'الحالة',
                    items: const {
                      'ACTIVE': 'نشط',
                      'SUSPENDED': 'موقوف',
                      'PENDING': 'بانتظار التفعيل',
                      'BANNED': 'محظور',
                    },
                    onChanged: (value) =>
                        setState(() => _accountStatus = value),
                  ),
                  if (_roles.contains(AppConstants.adminRole)) ...[
                    const SizedBox(height: 16),
                    _AdminSubRolesSelector(
                      selected: _adminSubRoles,
                      onChanged: (selected) =>
                          setState(() => _adminSubRoles = selected),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AdminUsersCubit>();
    if (_isEditing) {
      await cubit.updateUser(
        user: widget.user!,
        name: _nameController.text.trim(),
        phone: _phoneController.text,
        roles: _roles.toList(),
        accountStatus: _accountStatus,
        password: _passwordController.text,
        adminSubRoles: _adminSubRoles.toList(),
      );
    } else {
      await cubit.createUser(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text,
        password: _passwordController.text,
        roles: _roles.toList(),
        accountStatus: _accountStatus,
        adminSubRoles: _adminSubRoles.toList(),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }
}

class _DialogDropdown extends StatelessWidget {
  final String value;
  final String label;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  const _DialogDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.of(context).surfaceColor,
      decoration: _inputDecoration(context, hintText: label),
      items: items.entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(ArabicNumberTransformer.transform(entry.value)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _RolesSelector extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const _RolesSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = {
      AppConstants.adminRole: 'مدير نظام',
      AppConstants.managerRole: 'مدير',
      AppConstants.seniorEngineerRole: 'مهندس أول',
      AppConstants.juniorEngineerRole: 'مهندس',
      AppConstants.siteEngineerRole: 'مهندس موقع',
      'designer': 'مصمم',
    };

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأدوار',
            style: AppTextStyles.of(context).caption.copyWith(
              color: AppColors.of(context).textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.entries.map((entry) {
              final isSelected = selected.contains(entry.key);
              return FilterChip(
                label: Text(ArabicNumberTransformer.transform(entry.value)),
                selected: isSelected,
                onSelected: (value) {
                  final next = {...selected};
                  value ? next.add(entry.key) : next.remove(entry.key);
                  if (next.isNotEmpty) onChanged(next);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AdminSubRolesSelector extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const _AdminSubRolesSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const items = {
      AppConstants.systemAdminSubRole: 'صلاحيات النظام',
      AppConstants.projectAdminSubRole: 'إدارة المشاريع',
      AppConstants.financialAdminSubRole: 'الإدارة المالية',
      AppConstants.technicalAdminSubRole: 'الإدارة الفنية',
    };

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.entries.map((entry) {
          final isSelected = selected.contains(entry.key);
          return FilterChip(
            label: Text(ArabicNumberTransformer.transform(entry.value)),
            selected: isSelected,
            onSelected: (value) {
              final next = {...selected};
              value ? next.add(entry.key) : next.remove(entry.key);
              onChanged(next);
            },
          );
        }).toList(),
      ),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context, {
  String? hintText,
  IconData? prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 18),
    filled: true,
    fillColor: AppColors.of(context).inputBackground,
    isDense: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.of(context).inputBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.of(context).inputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.of(context).inputFocusBorder),
    ),
  );
}

ButtonStyle _toolbarButtonStyle(
  BuildContext context, {
  required EdgeInsetsGeometry padding,
  double disabledOpacity = 0.5,
}) {
  return ButtonStyle(
    padding: WidgetStatePropertyAll(padding),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return AppColors.of(
          context,
        ).surfaceColor.withValues(alpha: disabledOpacity);
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.of(context).tableRowHover;
      }
      return AppColors.of(context).surfaceColor;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return AppColors.of(context).textDisabled;
      }
      return AppColors.of(context).textPrimary;
    }),
    iconColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return AppColors.of(context).textDisabled;
      }
      return AppColors.of(context).primary;
    }),
    side: WidgetStateProperty.resolveWith((states) {
      final color = states.contains(WidgetState.hovered)
          ? AppColors.of(context).primaryDark
          : AppColors.of(context).border;
      return BorderSide(color: color);
    }),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    overlayColor: WidgetStatePropertyAll(
      AppColors.of(context).primary.withValues(alpha: 0.08),
    ),
  );
}

Future<void> _showUserDialog({required BuildContext context, User? user}) {
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: context.read<AdminUsersCubit>(),
      child: _UserFormDialog(user: user),
    ),
  );
}

String _roleLabel(String role) {
  switch (role) {
    case AppConstants.adminRole:
      return 'مدير نظام';
    case AppConstants.managerRole:
      return 'مدير';
    case AppConstants.seniorEngineerRole:
      return 'مهندس أول';
    case AppConstants.juniorEngineerRole:
      return 'مهندس';
    case AppConstants.siteEngineerRole:
      return 'مهندس موقع';
    case 'designer':
      return 'مصمم';
    default:
      return role;
  }
}
