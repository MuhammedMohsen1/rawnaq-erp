import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/role_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/datasources/recently_deleted_api_datasource.dart';

class RecentlyDeletedPage extends StatefulWidget {
  const RecentlyDeletedPage({super.key});

  @override
  State<RecentlyDeletedPage> createState() => _RecentlyDeletedPageState();
}

class _RecentlyDeletedPageState extends State<RecentlyDeletedPage> {
  final RecentlyDeletedApiDataSource _dataSource =
      RecentlyDeletedApiDataSource();
  final TextEditingController _pinController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  List<RecentlyDeletedItem> _items = const [];
  String? _pin;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isRestoring = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated ||
            !RoleUtils.canAccessAdmin(authState.user)) {
          return const Directionality(
            textDirection: TextDirection.rtl,
            child: _AccessDeniedView(),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _pin == null ? _buildPinGate() : _buildDeletedList(),
          ),
        );
      },
    );
  }

  Widget _buildPinGate() {
    return Center(
      child: SizedBox(
        width: 420,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 36,
                ),
                const SizedBox(height: 16),
                Text(
                  'العناصر المحذوفة مؤخراً',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'أدخل رمز المدير',
                    hintStyle: AppTextStyles.bodyMedium,
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: _inputBorder(AppColors.inputBorder),
                    enabledBorder: _inputBorder(AppColors.inputBorder),
                    focusedBorder: _inputBorder(AppColors.primary),
                  ),
                  onSubmitted: (_) => _unlock(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _unlock,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_open, size: 18),
                    label: const Text('فتح'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'العناصر المحذوفة مؤخراً',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'تحديث',
              onPressed: _isLoading ? null : _loadItems,
              icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد عناصر محذوفة',
                      style: AppTextStyles.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.divider),
                    itemBuilder: (context, index) => _DeletedItemRow(
                      item: _items[index],
                      dateText: _dateFormat.format(_items[index].deletedAt),
                      isBusy: _isRestoring,
                      onRestore: () => _restore(_items[index]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _unlock() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'الرمز مطلوب');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _dataSource.getItems(pin);
      setState(() {
        _pin = pin;
        _items = items;
      });
    } catch (_) {
      setState(() => _errorMessage = 'تعذر فتح الصفحة. تحقق من الرمز.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadItems() async {
    final pin = _pin;
    if (pin == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _dataSource.getItems(pin);
      setState(() => _items = items);
    } catch (_) {
      setState(() => _errorMessage = 'فشل تحميل العناصر المحذوفة');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restore(RecentlyDeletedItem item) async {
    final pin = _pin;
    if (pin == null || !item.canRestore) return;

    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      await _dataSource.restore(id: item.id, type: item.type, pin: pin);
      final items = await _dataSource.getItems(pin);
      setState(() => _items = items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تمت الاستعادة بنجاح',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      setState(() => _errorMessage = 'فشلت الاستعادة');
    } finally {
      setState(() => _isRestoring = false);
    }
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}

class _DeletedItemRow extends StatelessWidget {
  final RecentlyDeletedItem item;
  final String dateText;
  final bool isBusy;
  final VoidCallback onRestore;

  const _DeletedItemRow({
    required this.item,
    required this.dateText,
    required this.isBusy,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceColor,
        child: Icon(_iconForType(item.type), color: AppColors.textSecondary),
      ),
      title: Text(
        item.title,
        style: AppTextStyles.tableCellBold,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          labelForType(item.type),
          item.subtitle,
          dateText,
        ].where((value) => value != null && value.isNotEmpty).join(' • '),
        style: AppTextStyles.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
        width: 112,
        child: OutlinedButton.icon(
          onPressed: item.canRestore && !isBusy ? onRestore : null,
          icon: const Icon(Icons.restore, size: 18),
          label: const Text('استعادة'),
        ),
      ),
    );
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'USER':
        return Icons.person_outline;
      case 'PROJECT':
        return Icons.folder_outlined;
      case 'PROJECT_ATTACHMENT':
        return Icons.attach_file;
      case 'TASK':
        return Icons.task_alt;
      case 'PRICING_ITEM':
      case 'PRICING_SUB_ITEM':
      case 'PRICING_ELEMENT':
        return Icons.receipt_long_outlined;
      default:
        return Icons.delete_outline;
    }
  }
}

String labelForType(String type) {
  switch (type) {
    case 'USER':
      return 'مستخدم';
    case 'PROJECT':
      return 'مشروع';
    case 'PROJECT_ATTACHMENT':
      return 'مرفق';
    case 'TASK':
      return 'مهمة';
    case 'PRICING_ITEM':
      return 'بند تسعير';
    case 'PRICING_SUB_ITEM':
      return 'بند فرعي';
    case 'PRICING_ELEMENT':
      return 'عنصر تكلفة';
    default:
      return 'عنصر';
  }
}

class _AccessDeniedView extends StatelessWidget {
  const _AccessDeniedView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('لا تملك صلاحية الوصول', style: AppTextStyles.bodyMedium),
    );
  }
}
