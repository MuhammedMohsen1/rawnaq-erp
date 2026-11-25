import 'package:rawnaq/core/widgets/app_toast.dart';
import 'package:rawnaq/core/utils/arabic_number_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/role_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/datasources/recently_deleted_api_datasource.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

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
            color: AppColors.of(context).cardBackground,
            border: Border.all(color: AppColors.of(context).border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: AppColors.of(context).primary,
                  size: 36,
                ),
                const SizedBox(height: 16),
                Text(
                  'العناصر المحذوفة مؤخراً',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    context,
                  ).h4.copyWith(color: AppColors.of(context).textPrimary),
                ),
                const SizedBox(height: 20),
                TextField(
                  inputFormatters: const [ArabicNumberInputFormatter()],
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    context,
                  ).h5.copyWith(color: AppColors.of(context).textPrimary),
                  decoration: InputDecoration(
                    hintText: 'أدخل رمز المدير',
                    hintStyle: AppTextStyles.of(context).bodyMedium,
                    filled: true,
                    fillColor: AppColors.of(context).inputBackground,
                    border: _inputBorder(AppColors.of(context).inputBorder),
                    enabledBorder: _inputBorder(
                      AppColors.of(context).inputBorder,
                    ),
                    focusedBorder: _inputBorder(AppColors.of(context).primary),
                  ),
                  onSubmitted: (_) => _unlock(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    ArabicNumberTransformer.transform(_errorMessage!),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.of(
                      context,
                    ).bodySmall.copyWith(color: AppColors.of(context).error),
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
              style: AppTextStyles.of(
                context,
              ).h4.copyWith(color: AppColors.of(context).textPrimary),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'تحديث',
              onPressed: _isLoading ? null : _loadItems,
              icon: Icon(
                Icons.refresh,
                color: AppColors.of(context).textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              ArabicNumberTransformer.transform(_errorMessage!),
              style: AppTextStyles.of(
                context,
              ).bodySmall.copyWith(color: AppColors.of(context).error),
            ),
          ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.of(context).cardBackground,
              border: Border.all(color: AppColors.of(context).border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد عناصر محذوفة',
                      style: AppTextStyles.of(context).bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: AppColors.of(context).divider),
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
          AppToast.build(
            tone: ToastTone.success,
            duration: const Duration(seconds: 2),
            content: Text(
              'تمت الاستعادة بنجاح',
              textDirection: TextDirection.rtl,
            ),
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
        backgroundColor: AppColors.of(context).surfaceColor,
        child: Icon(
          _iconForType(item.type),
          color: AppColors.of(context).textSecondary,
        ),
      ),
      title: Text(
        ArabicNumberTransformer.transform(item.title),
        style: AppTextStyles.of(context).tableCellBold,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        ArabicNumberTransformer.transform(
          [
            labelForType(item.type),
            item.subtitle,
            dateText,
          ].where((value) => value != null && value.isNotEmpty).join(' • '),
        ),
        style: AppTextStyles.of(context).bodySmall,
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
    return Center(
      child: Text(
        'لا تملك صلاحية الوصول',
        style: AppTextStyles.of(context).bodyMedium,
      ),
    );
  }
}
