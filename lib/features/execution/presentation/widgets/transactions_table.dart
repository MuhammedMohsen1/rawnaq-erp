import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/dialog_keyboard_actions.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../data/models/execution_models.dart';
import '../../domain/enums/transaction_type.dart';
import '../cubit/execution_cubit.dart';

/// Converts Arabic numerals (٠١٢٣٤٥٦٧٨٩) to English numerals (0123456789)
String _convertArabicToEnglishNumerals(String input) {
  const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const englishNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  String result = input;
  for (int i = 0; i < arabicNumerals.length; i++) {
    result = result.replaceAll(arabicNumerals[i], englishNumerals[i]);
  }
  // Also handle Arabic decimal separator
  result = result.replaceAll('٫', '.');
  return result;
}

/// Parse a number string that may contain Arabic numerals
double? _parseNumber(String text) {
  final normalized = _convertArabicToEnglishNumerals(text.trim());
  return double.tryParse(normalized);
}

class TransactionsTable extends StatelessWidget {
  final ProjectEntity project;
  final List<TransactionModel> transactions;
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isAddingExpense;
  final bool isAddingIncome;
  final Map<String, bool> editingTransactions;
  final bool isLoadingMore;
  final bool hasMoreTransactions;

  /// Whether the user can request installments (engineers)
  final bool isSiteEngineer;
  final bool isAdminOrManager;
  final List<PaymentPhaseModel> paymentSchedule;
  final List<InstallmentRequestModel> pendingInstallmentRequests;
  final double profitPercentage;
  final VoidCallback? onAddExpense;
  final VoidCallback? onAddIncome;
  final VoidCallback? onRequestInstallment;
  final VoidCallback onLoadMore;

  const TransactionsTable({
    super.key,
    required this.project,
    required this.transactions,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    this.startDate,
    this.endDate,
    required this.isAddingExpense,
    this.isAddingIncome = false,
    required this.editingTransactions,
    required this.isLoadingMore,
    required this.hasMoreTransactions,
    required this.isSiteEngineer,
    required this.isAdminOrManager,
    required this.paymentSchedule,
    required this.pendingInstallmentRequests,
    required this.profitPercentage,
    this.onAddExpense,
    this.onAddIncome,
    this.onRequestInstallment,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _ExpenseSummaryStrip(
                totalReceived: totalReceived,
                totalExpenses: totalExpenses,
                netCashFlow: netCashFlow,
                startDate: startDate,
                endDate: endDate,
                isCompact: isCompact,
              ),
              const Divider(height: 1, color: AppColors.border),
              // Header with actions
              _TableHeader(
                onAddExpense: onAddExpense == null
                    ? null
                    : () => _showAddExpenseDialog(context, isCompact),
                onAddIncome: onAddIncome == null
                    ? null
                    : () => _showAddIncomeDialog(context, isCompact),
                onRequestInstallment: onRequestInstallment,
                isSiteEngineer: isSiteEngineer,
                isAdminOrManager: isAdminOrManager,
                isCompact: isCompact,
              ),
              const Divider(height: 1, color: AppColors.border),
              // Column headers
              if (!isCompact) ...[
                _ColumnHeaders(),
                const Divider(height: 1, color: AppColors.border),
              ],
              // Transaction rows
              ...transactions.map((transaction) {
                final isEditing = editingTransactions[transaction.id] ?? false;
                InstallmentRequestModel? pendingRequest;
                String? requestId = transaction.requestId;
                for (final request in pendingInstallmentRequests) {
                  if (request.id == requestId) {
                    pendingRequest = request;
                    break;
                  }
                }
                if (pendingRequest == null) {
                  for (final request in pendingInstallmentRequests) {
                    if (request.phaseName == transaction.description ||
                        request.phaseName == transaction.subDescription) {
                      pendingRequest = request;
                      break;
                    }
                  }
                }
                requestId ??= pendingRequest?.id;
                final installmentRequestId = requestId ?? transaction.id;
                return _TransactionRow(
                  projectId: project.id,
                  transaction: transaction,
                  isEditing: isEditing,
                  isCompact: isCompact,
                  isAdminOrManager: isAdminOrManager,
                  installmentRequestId: installmentRequestId,
                );
              }),
              // Load more button
              if (hasMoreTransactions)
                _LoadMoreButton(
                  isLoading: isLoadingMore,
                  onLoadMore: onLoadMore,
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExpenseDialog(BuildContext context, bool isCompact) {
    final cubit = context.read<ExecutionCubit>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _AddExpenseRow(
            projectId: project.id,
            onCancel: () => Navigator.of(dialogContext).pop(),
            isCompact: true,
            cubit: cubit,
          ),
        ),
      ),
    );
  }

  void _showAddIncomeDialog(BuildContext context, bool isCompact) {
    final cubit = context.read<ExecutionCubit>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _AddIncomeRow(
            projectId: project.id,
            onCancel: () => Navigator.of(dialogContext).pop(),
            isCompact: true,
            cubit: cubit,
          ),
        ),
      ),
    );
  }
}

class _ExpenseSummaryStrip extends StatefulWidget {
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCompact;

  const _ExpenseSummaryStrip({
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    this.startDate,
    this.endDate,
    required this.isCompact,
  });

  @override
  State<_ExpenseSummaryStrip> createState() => _ExpenseSummaryStripState();
}

class _ExpenseSummaryStripState extends State<_ExpenseSummaryStrip> {
  bool _isDetailsExpanded = false;

  String _formatMoney(double value) => '${value.toStringAsFixed(3)} د.ك';

  String get _deliveryValue {
    if (widget.endDate == null) return 'غير متاح';
    return DateFormat('d MMMM', 'ar').format(widget.endDate!);
  }

  String get _deliveryDetail {
    if (widget.startDate == null ||
        widget.endDate == null ||
        widget.endDate!.isBefore(widget.startDate!)) {
      return 'لا توجد بيانات كافية';
    }

    final today = _dateOnly(DateTime.now());
    final deliveryDay = _dateOnly(widget.endDate!);
    final daysLeft = deliveryDay.difference(today).inDays;
    if (daysLeft < 0) return 'متأخر ${daysLeft.abs()} يوم';
    if (daysLeft == 0) return 'اليوم';
    return 'متبقي $daysLeft يوم';
  }

  Color get _netCashColor {
    if (widget.netCashFlow < 0) return AppColors.error;
    if (widget.netCashFlow == 0) return AppColors.warning;
    return AppColors.primary;
  }

  Color get _deliveryColor {
    if (widget.endDate == null) return AppColors.textSecondary;
    return _dateOnly(widget.endDate!).isBefore(_dateOnly(DateTime.now()))
        ? AppColors.warning
        : AppColors.info;
  }

  double get _netCashProgress {
    if (widget.totalReceived <= 0 || widget.netCashFlow <= 0) return 0;
    return (widget.netCashFlow / widget.totalReceived).clamp(0.0, 1.0);
  }

  double get _deliveryProgress {
    if (widget.startDate == null ||
        widget.endDate == null ||
        widget.endDate!.isBefore(widget.startDate!)) {
      return 0;
    }

    final start = _dateOnly(widget.startDate!);
    final end = _dateOnly(widget.endDate!);
    final today = _dateOnly(DateTime.now());
    final totalDays = end.difference(start).inDays;
    if (totalDays <= 0) return 1;

    final elapsedDays = today.difference(start).inDays.clamp(0, totalDays);
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return _CompactProgressStrip(
                netCashValue: _formatMoney(widget.netCashFlow),
                netCashProgress: _netCashProgress,
                netCashColor: _netCashColor,
                deliveryValue: _deliveryValue,
                deliveryDetail: _deliveryDetail,
                deliveryProgress: _deliveryProgress,
                deliveryColor: _deliveryColor,
                isExpanded: _isDetailsExpanded,
                onToggleDetails: () {
                  setState(() => _isDetailsExpanded = !_isDetailsExpanded);
                },
              );
            },
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _StatsDetailsPanel(
                totalReceived: widget.totalReceived,
                totalExpenses: widget.totalExpenses,
                netCashFlow: widget.netCashFlow,
                deliveryValue: _deliveryValue,
                deliveryDetail: _deliveryDetail,
                netCashColor: _netCashColor,
                deliveryColor: _deliveryColor,
              ),
            ),
            crossFadeState: _isDetailsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class _StatsDetailsPanel extends StatelessWidget {
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final String deliveryValue;
  final String deliveryDetail;
  final Color netCashColor;
  final Color deliveryColor;

  const _StatsDetailsPanel({
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.deliveryValue,
    required this.deliveryDetail,
    required this.netCashColor,
    required this.deliveryColor,
  });

  String _formatMoney(double value) => '${value.toStringAsFixed(3)} د.ك';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = constraints.maxWidth < 520 ? 8.0 : 10.0;
          final columns = constraints.maxWidth < 520 ? 1 : 2;
          final width =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          final items = [
            _ExpenseSummaryTile(
              title: 'إجمالي الدخل',
              value: _formatMoney(totalReceived),
              detail: 'All income',
              icon: Icons.south_west_rounded,
              color: AppColors.success,
            ),
            _ExpenseSummaryTile(
              title: 'إجمالي المصروفات',
              value: _formatMoney(totalExpenses),
              detail: 'All outcome',
              icon: Icons.north_east_rounded,
              color: AppColors.error,
            ),
            _ExpenseSummaryTile(
              title: 'السيولة',
              value: _formatMoney(netCashFlow),
              detail: 'Net Cash',
              icon: Icons.account_balance_wallet_rounded,
              color: netCashColor,
            ),
            _ExpenseSummaryTile(
              title: 'يوم التسليم',
              value: deliveryValue,
              detail: deliveryDetail,
              icon: Icons.event_available_rounded,
              color: deliveryColor,
            ),
          ];

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final item in items) SizedBox(width: width, child: item),
            ],
          );
        },
      ),
    );
  }
}

class _CompactProgressStrip extends StatelessWidget {
  final String netCashValue;
  final double netCashProgress;
  final Color netCashColor;
  final String deliveryValue;
  final String deliveryDetail;
  final double deliveryProgress;
  final Color deliveryColor;
  final bool isExpanded;
  final VoidCallback onToggleDetails;

  const _CompactProgressStrip({
    required this.netCashValue,
    required this.netCashProgress,
    required this.netCashColor,
    required this.deliveryValue,
    required this.deliveryDetail,
    required this.deliveryProgress,
    required this.deliveryColor,
    required this.isExpanded,
    required this.onToggleDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ProgressSummaryCircle(
              title: 'السيولة',
              value: netCashValue,
              progress: netCashProgress,
              color: netCashColor,
            ),
          ),
          Container(width: 1, height: 58, color: AppColors.border),
          Expanded(
            child: _ProgressSummaryCircle(
              title: 'يوم التسليم',
              value: deliveryValue,
              detail: deliveryDetail,
              progress: deliveryProgress,
              color: deliveryColor,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onToggleDetails,
            icon: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
            ),
            color: AppColors.textSecondary,
            tooltip: 'تفاصيل الإحصائيات',
          ),
        ],
      ),
    );
  }
}

class _ProgressSummaryCircle extends StatelessWidget {
  final String title;
  final String value;
  final String? detail;
  final double progress;
  final Color color;

  const _ProgressSummaryCircle({
    required this.title,
    required this.value,
    this.detail,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 54,
          height: 54,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '$percent%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  maxLines: 1,
                  style: AppTextStyles.tableCellBold.copyWith(color: color),
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 2),
                Text(
                  detail!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpenseSummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  const _ExpenseSummaryTile({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: AppTextStyles.h6.copyWith(color: color),
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

class _TableHeader extends StatelessWidget {
  final VoidCallback? onAddExpense;
  final VoidCallback? onAddIncome;
  final VoidCallback? onRequestInstallment;
  final bool isSiteEngineer;
  final bool isAdminOrManager;
  final bool isCompact;

  const _TableHeader({
    this.onAddExpense,
    this.onAddIncome,
    this.onRequestInstallment,
    required this.isSiteEngineer,
    required this.isAdminOrManager,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    // Show request installment button for Site Engineer
    final showRequestInstallment =
        isSiteEngineer && onRequestInstallment != null;

    List<Widget> spaced(List<Widget> children) {
      if (children.isEmpty) return [];
      final spacedChildren = <Widget>[];
      for (int i = 0; i < children.length; i++) {
        spacedChildren.add(children[i]);
        if (i != children.length - 1) {
          spacedChildren.add(const SizedBox(width: 12));
        }
      }
      return spacedChildren;
    }

    final actions = <Widget>[
      if (isAdminOrManager && onAddIncome != null)
        ElevatedButton.icon(
          onPressed: onAddIncome,
          icon: const Icon(Icons.arrow_downward, size: 18),
          label: const Text('إضافة إيراد'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      if (onAddExpense != null)
        ElevatedButton.icon(
          onPressed: onAddExpense,
          icon: const Icon(Icons.arrow_upward, size: 18),
          label: const Text('إضافة مصروف'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: isCompact
            ? Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: actions,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: spaced(actions),
              ),
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.scaffoldBackground,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text('النوع', style: AppTextStyles.tableHeader),
          ),
          Expanded(
            flex: 3,
            child: Text('الوصف / البند', style: AppTextStyles.tableHeader),
          ),
          SizedBox(
            width: 120,
            child: Text('التاريخ', style: AppTextStyles.tableHeader),
          ),
          SizedBox(
            width: 140,
            child: Text(
              'المبلغ',
              style: AppTextStyles.tableHeader,
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'إجراءات',
              style: AppTextStyles.tableHeader,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String projectId;
  final TransactionModel transaction;
  final bool isEditing;
  final bool isCompact;
  final bool isAdminOrManager;
  final String installmentRequestId;

  const _TransactionRow({
    required this.projectId,
    required this.transaction,
    required this.isEditing,
    required this.isCompact,
    required this.isAdminOrManager,
    required this.installmentRequestId,
  });

  @override
  Widget build(BuildContext context) {
    final isInstallment = transaction.source.toLowerCase() == 'installment';
    final canEditInstallment = isAdminOrManager && isInstallment;

    if (isEditing && canEditInstallment) {
      return _EditableInstallmentRow(
        projectId: projectId,
        transaction: transaction,
        installmentRequestId: installmentRequestId,
        onCancel: () =>
            context.read<ExecutionCubit>().cancelEditing(transaction.id),
        isCompact: isCompact,
      );
    }

    if (isEditing && transaction.isEditable) {
      return _EditableExpenseRow(
        projectId: projectId,
        transaction: transaction,
        onCancel: () =>
            context.read<ExecutionCubit>().cancelEditing(transaction.id),
        isCompact: isCompact,
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    final isIncome = transaction.type == TransactionType.income;

    final canEdit = isInstallment ? canEditInstallment : transaction.isEditable;

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isIncome
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.success : AppColors.error,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.tableCellBold.copyWith(fontSize: 13),
                  ),
                  if (transaction.subDescription != null)
                    Text(
                      transaction.subDescription!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  Text(
                    dateFormat.format(transaction.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : ''}${transaction.amount.toStringAsFixed(3)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tableCellBold.copyWith(
                    color: isIncome ? AppColors.success : AppColors.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.end,
                ),
                if (canEdit)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => context
                              .read<ExecutionCubit>()
                              .toggleEditing(transaction.id),
                          icon: const Icon(Icons.edit, size: 15),
                          tooltip: 'تعديل',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => isInstallment
                              ? _showDeleteInstallmentConfirmation(
                                  context,
                                  installmentRequestId,
                                )
                              : _showDeleteConfirmation(
                                  context,
                                  transaction.id,
                                ),
                          icon: const Icon(Icons.delete_outline, size: 15),
                          tooltip: 'حذف',
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // Type icon
          SizedBox(
            width: 60,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isIncome
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.success : AppColors.error,
                size: 18,
              ),
            ),
          ),
          // Description
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.tableCellBold,
                ),
                if (transaction.subDescription != null)
                  Text(
                    transaction.subDescription!,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
          // Date
          SizedBox(
            width: 120,
            child: Text(
              dateFormat.format(transaction.date),
              style: AppTextStyles.tableCell,
            ),
          ),
          // Amount
          SizedBox(
            width: 140,
            child: Text(
              '${isIncome ? '+' : ''}${transaction.amount.toStringAsFixed(3)}',
              style: AppTextStyles.tableCellBold.copyWith(
                color: isIncome ? AppColors.success : AppColors.error,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          // Actions
          SizedBox(
            width: 100,
            child: canEdit
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => context
                            .read<ExecutionCubit>()
                            .toggleEditing(transaction.id),
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'تعديل',
                        color: AppColors.textSecondary,
                      ),
                      IconButton(
                        onPressed: () => isInstallment
                            ? _showDeleteInstallmentConfirmation(
                                context,
                                installmentRequestId,
                              )
                            : _showDeleteConfirmation(context, transaction.id),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        tooltip: 'حذف',
                        color: AppColors.error,
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ExecutionCubit>().deleteExpense(
                projectId,
                transactionId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showDeleteInstallmentConfirmation(
    BuildContext context,
    String installmentId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الدفعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await context.read<ExecutionCubit>().deleteInstallment(
                  projectId,
                  installmentId,
                );
              } catch (e) {
                if (context.mounted) {
                  final message = 'فشل حذف الدفعة: ${e.toString()}';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _AddExpenseRow extends StatefulWidget {
  final String projectId;
  final VoidCallback onCancel;
  final bool isCompact;
  final ExecutionCubit cubit;

  const _AddExpenseRow({
    required this.projectId,
    required this.onCancel,
    required this.isCompact,
    required this.cubit,
  });

  @override
  State<_AddExpenseRow> createState() => _AddExpenseRowState();
}

class _AddExpenseRowState extends State<_AddExpenseRow> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _quantityController = TextEditingController();
  CostType _costType = CostType.total;
  DateTime _selectedDate = DateTime.now();
  bool _isReturnedExpense = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitCostController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogKeyboardActions(
      enabled: !_isSubmitting,
      onSubmit: _submitExpense,
      onClose: widget.onCancel,
      child: BlocProvider.value(
        value: widget.cubit,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.background.withValues(alpha: 0.05),
          child: widget.isCompact ? _buildCompactForm() : _buildWideForm(),
        ),
      ),
    );
  }

  Widget _buildCompactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: AppColors.error,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text('إضافة مصروف', style: AppTextStyles.tableCellBold),
          ],
        ),
        const SizedBox(height: 12),
        if (_costType == CostType.total)
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              hintText: 'المبلغ',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _unitCostController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'سعر الوحدة',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'الكمية',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),

        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'اسم البند',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _isReturnedExpense,
          onChanged: (value) {
            setState(() => _isReturnedExpense = value ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'مرتجع مصروف',
            style: AppTextStyles.tableCellBold.copyWith(
              color: AppColors.success,
            ),
          ),
          subtitle: Text(
            'استخدمها عند إرجاع بقايا خامات مثل الخشب',
            style: AppTextStyles.caption,
          ),
        ),
        // DropdownButtonFormField<CostType>(
        //   value: _costType,
        //   decoration: const InputDecoration(
        //     isDense: true,
        //     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        //   ),
        //   items: const [
        //     DropdownMenuItem(value: CostType.total, child: Text('إجمالي')),
        //     DropdownMenuItem(value: CostType.unitBased, child: Text('وحدة')),
        //   ],
        //   onChanged: (value) {
        //     if (value != null) setState(() => _costType = value);
        //   },
        // ),
        // const SizedBox(height: 8),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: _isSubmitting ? null : _submitExpense,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppColors.success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideForm() {
    return Row(
      children: [
        // Type icon placeholder
        SizedBox(
          width: 60,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: AppColors.error,
              size: 18,
            ),
          ),
        ),
        // Name input
        Expanded(
          flex: 2,
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'اسم البند',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // // Cost type dropdown
        // SizedBox(
        //   width: 120,
        //   child: DropdownButtonFormField<CostType>(
        //     value: _costType,
        //     decoration: const InputDecoration(
        //       isDense: true,
        //       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //     ),
        //     items: const [
        //       DropdownMenuItem(value: CostType.total, child: Text('إجمالي')),
        //       DropdownMenuItem(value: CostType.unitBased, child: Text('وحدة')),
        //     ],
        //     onChanged: (value) {
        //       if (value != null) setState(() => _costType = value);
        //     },
        //   ),
        // ),
        // const SizedBox(width: 8),
        // Amount or Unit cost + Quantity
        if (_costType == CostType.total)
          SizedBox(
            width: 120,
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'المبلغ',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          )
        else ...[
          SizedBox(
            width: 80,
            child: TextField(
              controller: _unitCostController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'سعر الوحدة',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('×'),
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'الكمية',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        SizedBox(
          width: 128,
          child: CheckboxListTile(
            value: _isReturnedExpense,
            onChanged: (value) {
              setState(() => _isReturnedExpense = value ?? false);
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'مرتجع',
              style: AppTextStyles.caption.copyWith(color: AppColors.success),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: _isSubmitting ? null : _submitExpense,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppColors.success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitExpense() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال اسم المصروف')));
      return;
    }

    double? amount;
    double? unitCost;
    double? quantity;

    if (_costType == CostType.total) {
      // Convert Arabic numerals to English before parsing
      amount = _parseNumber(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')));
        return;
      }
    } else {
      // Convert Arabic numerals to English before parsing
      unitCost = _parseNumber(_unitCostController.text);
      quantity = _parseNumber(_quantityController.text);
      if (unitCost == null ||
          quantity == null ||
          unitCost <= 0 ||
          quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال سعر الوحدة والكمية')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = CreateExpenseDto(
        name: name,
        type: _isReturnedExpense ? 'RETURNED' : 'DAILY',
        costType: _costType == CostType.total ? 'TOTAL' : 'UNIT_BASED',
        amount: amount,
        unitCost: unitCost,
        quantity: quantity,
        date: _selectedDate,
      );

      await widget.cubit.addExpense(widget.projectId, dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة المصروف بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onCancel();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إضافة المصروف: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _EditableExpenseRow extends StatefulWidget {
  final String projectId;
  final TransactionModel transaction;
  final VoidCallback onCancel;
  final bool isCompact;

  const _EditableExpenseRow({
    required this.projectId,
    required this.transaction,
    required this.onCancel,
    required this.isCompact,
  });

  @override
  State<_EditableExpenseRow> createState() => _EditableExpenseRowState();
}

class _EditableExpenseRowState extends State<_EditableExpenseRow> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _unitCostController;
  late TextEditingController _quantityController;
  late CostType _costType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.transaction.description,
    );
    _costType = widget.transaction.costType ?? CostType.total;

    if (_costType == CostType.total) {
      _amountController = TextEditingController(
        text: widget.transaction.amount.abs().toString(),
      );
      _unitCostController = TextEditingController();
      _quantityController = TextEditingController();
    } else {
      _amountController = TextEditingController();
      _unitCostController = TextEditingController(
        text: widget.transaction.unitCost?.toString() ?? '',
      );
      _quantityController = TextEditingController(
        text: widget.transaction.quantity?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitCostController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogKeyboardActions(
      enabled: !_isSubmitting,
      onSubmit: _submitUpdate,
      onClose: widget.onCancel,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.primary.withValues(alpha: 0.05),
        child: widget.isCompact ? _buildCompactForm() : _buildWideForm(),
      ),
    );
  }

  Widget _buildCompactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: AppColors.error,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text('تعديل المصروف', style: AppTextStyles.tableCellBold),
          ],
        ),

        const SizedBox(height: 8),
        if (_costType == CostType.total)
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              hintText: 'المبلغ',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _unitCostController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'سعر الوحدة',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'الكمية',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'اسم المصروف',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: _isSubmitting ? null : _submitUpdate,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppColors.success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideForm() {
    return Row(
      children: [
        // Type icon
        SizedBox(
          width: 60,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: AppColors.error,
              size: 18,
            ),
          ),
        ),
        // Name input
        Expanded(
          flex: 2,
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'اسم المصروف',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // // Cost type dropdown
        // SizedBox(
        //   width: 120,
        //   child: DropdownButtonFormField<CostType>(
        //     value: _costType,
        //     decoration: const InputDecoration(
        //       isDense: true,
        //       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //     ),
        //     items: const [
        //       DropdownMenuItem(value: CostType.total, child: Text('إجمالي')),
        //       DropdownMenuItem(value: CostType.unitBased, child: Text('وحدة')),
        //     ],
        //     onChanged: (value) {
        //       if (value != null) setState(() => _costType = value);
        //     },
        //   ),
        // ),
        // const SizedBox(width: 8),
        // Amount or Unit cost + Quantity
        if (_costType == CostType.total)
          SizedBox(
            width: 120,
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'المبلغ',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          )
        else ...[
          SizedBox(
            width: 80,
            child: TextField(
              controller: _unitCostController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'سعر الوحدة',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('×'),
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                hintText: 'الكمية',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: _isSubmitting ? null : _submitUpdate,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppColors.success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitUpdate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال اسم المصروف')));
      return;
    }

    double? amount;
    double? unitCost;
    double? quantity;

    if (_costType == CostType.total) {
      amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')));
        return;
      }
    } else {
      unitCost = double.tryParse(_unitCostController.text);
      quantity = double.tryParse(_quantityController.text);
      if (unitCost == null ||
          quantity == null ||
          unitCost <= 0 ||
          quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال سعر الوحدة والكمية')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = UpdateExpenseDto(
        name: name,
        costType: _costType == CostType.total ? 'TOTAL' : 'UNIT_BASED',
        amount: amount,
        unitCost: unitCost,
        quantity: quantity,
      );

      // Get cubit from context before async gap
      final cubit = context.read<ExecutionCubit>();
      await cubit.updateExpense(widget.projectId, widget.transaction.id, dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المصروف بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث المصروف: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _EditableInstallmentRow extends StatefulWidget {
  final String projectId;
  final TransactionModel transaction;
  final String installmentRequestId;
  final VoidCallback onCancel;
  final bool isCompact;

  const _EditableInstallmentRow({
    required this.projectId,
    required this.transaction,
    required this.installmentRequestId,
    required this.onCancel,
    required this.isCompact,
  });

  @override
  State<_EditableInstallmentRow> createState() =>
      _EditableInstallmentRowState();
}

class _EditableInstallmentRowState extends State<_EditableInstallmentRow> {
  late TextEditingController _nameController;
  late TextEditingController _originalAmountController;
  late TextEditingController _requestedAmountController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.transaction.description,
    );
    _originalAmountController = TextEditingController();
    _requestedAmountController = TextEditingController(
      text: widget.transaction.amount.abs().toString(),
    );
    if (widget.transaction.originalAmount != null) {
      _originalAmountController.text = widget.transaction.originalAmount!
          .toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originalAmountController.dispose();
    _requestedAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogKeyboardActions(
      enabled: !_isSubmitting,
      onSubmit: _submitUpdate,
      onClose: widget.onCancel,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.primary.withValues(alpha: 0.05),
        child: widget.isCompact ? _buildCompactForm() : _buildWideForm(),
      ),
    );
  }

  Widget _buildCompactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_downward,
                color: AppColors.success,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text('تعديل الدفعة', style: AppTextStyles.tableCellBold),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'اسم الدفعة',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _originalAmountController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          decoration: const InputDecoration(
            hintText: 'المبلغ الأصلي',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _requestedAmountController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          decoration: const InputDecoration(
            hintText: 'المبلغ المطلوب',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: _isSubmitting ? null : _submitUpdate,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppColors.success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideForm() {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: AppColors.success,
              size: 18,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'اسم الدفعة',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextField(
            controller: _originalAmountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              hintText: 'المبلغ الأصلي',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextField(
            controller: _requestedAmountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              hintText: 'المبلغ المطلوب',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: _isSubmitting ? null : _submitUpdate,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppColors.success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitUpdate() async {
    final name = _nameController.text.trim();
    final originalAmount = _parseNumber(_originalAmountController.text);
    final requestedAmount = _parseNumber(_requestedAmountController.text);

    final hasOriginal = originalAmount != null && originalAmount > 0;
    final hasRequested = requestedAmount != null && requestedAmount > 0;

    if (name.isEmpty && !hasOriginal && !hasRequested) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الاسم أو المبالغ')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = UpdateInstallmentDto(
        phaseName: name.isEmpty ? null : name,
        originalAmount: hasOriginal ? originalAmount : null,
        requestedAmount: hasRequested ? requestedAmount : null,
      );
      final cubit = context.read<ExecutionCubit>();
      await cubit.updateInstallment(
        widget.projectId,
        widget.installmentRequestId,
        dto,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الدفعة بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = 'فشل تحديث الدفعة: ${e.toString()}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
        context.read<ExecutionCubit>().cancelEditing(widget.transaction.id);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLoadMore;

  const _LoadMoreButton({required this.isLoading, required this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: onLoadMore,
                child: Text(
                  'تحميل المزيد من المعاملات',
                  style: AppTextStyles.link,
                ),
              ),
      ),
    );
  }
}

/// Add income row for Admin/Manager to directly add income
class _AddIncomeRow extends StatefulWidget {
  final String projectId;
  final VoidCallback onCancel;
  final bool isCompact;
  final ExecutionCubit cubit;
  const _AddIncomeRow({
    required this.projectId,
    required this.onCancel,
    required this.isCompact,
    required this.cubit,
  });

  @override
  State<_AddIncomeRow> createState() => _AddIncomeRowState();
}

class _AddIncomeRowState extends State<_AddIncomeRow> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogKeyboardActions(
      enabled: !_isSubmitting,
      onSubmit: _submitIncome,
      onClose: widget.onCancel,
      child: BlocProvider.value(
        value: widget.cubit,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.background.withValues(alpha: 0.05),
          child: widget.isCompact ? _buildCompactForm() : _buildWideForm(),
        ),
      ),
    );
  }

  Widget _buildCompactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_downward,
                color: AppColors.success,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text('إضافة إيراد', style: AppTextStyles.tableCellBold),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          decoration: const InputDecoration(
            hintText: 'المبلغ',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),

        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'وصف الإيراد (مثال: دفعة العميل)',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: _isSubmitting ? null : _submitIncome,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppColors.success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideForm() {
    return Row(
      children: [
        // Type icon (income)
        SizedBox(
          width: 60,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: AppColors.success,
              size: 18,
            ),
          ),
        ),
        // Description input
        Expanded(
          flex: 2,
          child: TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'وصف الإيراد (مثال: دفعة العميل)',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Date picker
        SizedBox(
          width: 130,
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Amount input
        SizedBox(
          width: 120,
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              hintText: 'المبلغ',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: _isSubmitting ? null : _submitIncome,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppColors.success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitIncome() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال وصف الإيراد')));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dto = CreateIncomeDto(
        description: description,
        amount: amount,
        date: _selectedDate,
      );

      await widget.cubit.addIncome(widget.projectId, dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الإيراد بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onCancel();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إضافة الإيراد: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
