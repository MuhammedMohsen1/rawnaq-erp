import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rawnaq/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ExpenseSummaryStrip extends StatefulWidget {
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final double totalCost;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCompact;

  const ExpenseSummaryStrip({
    super.key,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.totalCost,
    this.startDate,
    this.endDate,
    required this.isCompact,
  });

  @override
  State<ExpenseSummaryStrip> createState() => _ExpenseSummaryStripState();
}

class _ExpenseSummaryStripState extends State<ExpenseSummaryStrip> {
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

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

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
                totalCost: widget.totalCost,
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
  final double totalCost;
  final String deliveryValue;
  final String deliveryDetail;
  final Color netCashColor;
  final Color deliveryColor;

  const _StatsDetailsPanel({
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.totalCost,
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
          final remainingFromCost = (totalCost - totalReceived).clamp(
            0.0,
            double.infinity,
          );
          final items = [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => _ExpenseSummaryTile(
                title: 'إجمالي الدخل',
                value: _formatMoney(totalReceived),
                detail:
                    (state as AuthAuthenticated).user.isAdmin && totalCost > 0
                    ? 'الباقي ${_formatMoney(remainingFromCost)} من ${_formatMoney(totalCost)}'
                    : 'لا توجد تكلفة إجمالية',
                icon: Icons.south_west_rounded,
                color: AppColors.success,
              ),
            ),
            _ExpenseSummaryTile(
              title: 'إجمالي المصروفات',
              value: _formatMoney(totalExpenses),
              detail: 'إجمالي الخارج',
              icon: Icons.north_east_rounded,
              color: AppColors.error,
            ),
            _ExpenseSummaryTile(
              title: 'السيولة',
              value: _formatMoney(netCashFlow),
              detail: 'الدخل ناقص المصروفات',
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
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
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

class TransactionsTableHeader extends StatelessWidget {
  final VoidCallback? onAddExpense;
  final VoidCallback? onAddIncome;
  final bool isSiteEngineer;
  final bool isAdminOrManager;
  final bool isCompact;

  const TransactionsTableHeader({
    super.key,
    this.onAddExpense,
    this.onAddIncome,
    required this.isSiteEngineer,
    required this.isAdminOrManager,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
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
            : Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
      ),
    );
  }
}

class TransactionsColumnHeaders extends StatelessWidget {
  const TransactionsColumnHeaders({super.key});

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
