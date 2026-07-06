import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class FinancialToolbar extends StatelessWidget {
  final int projectCount;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final String? selectedPeriod;
  final String? selectedProjectType;
  final DateTimeRange? customRange;
  final ValueChanged<String?> onPeriodChanged;
  final ValueChanged<String?> onProjectTypeChanged;
  final ValueChanged<DateTimeRange> onCustomRangeChanged;

  const FinancialToolbar({
    super.key,
    required this.projectCount,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.selectedPeriod,
    required this.selectedProjectType,
    required this.customRange,
    required this.onPeriodChanged,
    required this.onProjectTypeChanged,
    required this.onCustomRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = SizedBox(
          width: constraints.maxWidth < 620 ? double.infinity : 340,
          child: TextField(
            onChanged: onSearchChanged,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: 'بحث بالمشروع أو العميل',
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.inputBackground,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.inputFocusBorder),
              ),
            ),
          ),
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$projectCount مشروع', style: AppTextStyles.label),
            const SizedBox(width: 12),
            Tooltip(
              message: 'تحديث',
              child: IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                color: AppColors.primary,
              ),
            ),
          ],
        );
        final filters = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilterSection(
              title: 'نوع المشروع',
              icon: Icons.category_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PeriodChip(
                    label: 'كل المشاريع',
                    selected: selectedProjectType == null,
                    onSelected: () => onProjectTypeChanged(null),
                  ),
                  _PeriodChip(
                    label: 'تصميم',
                    selected: selectedProjectType == 'DESIGN',
                    onSelected: () => onProjectTypeChanged('DESIGN'),
                  ),
                  _PeriodChip(
                    label: 'تنفيذ',
                    selected: selectedProjectType == 'EXECUTION',
                    onSelected: () => onProjectTypeChanged('EXECUTION'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FilterSection(
              title: 'النطاق الزمني',
              icon: Icons.date_range_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PeriodChip(
                    label: 'الكل',
                    selected: selectedPeriod == null && customRange == null,
                    onSelected: () => onPeriodChanged(null),
                  ),
                  for (final option in const [
                    ('WEEK', 'أسبوع'),
                    ('MONTH', 'شهر'),
                    ('YEAR', 'سنة'),
                  ])
                    _PeriodChip(
                      label: option.$2,
                      selected: selectedPeriod == option.$1,
                      onSelected: () => onPeriodChanged(option.$1),
                    ),
                  _PeriodChip(
                    label: customRange == null
                        ? 'فترة مخصصة'
                        : '${DateFormat('yyyy/MM/dd').format(customRange!.start)} - '
                              '${DateFormat('yyyy/MM/dd').format(customRange!.end)}',
                    selected: customRange != null,
                    onSelected: () => _pickRange(context),
                  ),
                ],
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField,
              const SizedBox(height: 12),
              filters,
              const SizedBox(height: 12),
              actions,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [searchField, const Spacer(), actions]),
            const SizedBox(height: 12),
            filters,
          ],
        );
      },
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final range = await showDialog<DateTimeRange>(
      context: context,
      builder: (_) => _CustomRangeDialog(initialRange: customRange),
    );
    if (range != null) onCustomRangeChanged(range);
  }
}

class _CustomRangeDialog extends StatefulWidget {
  final DateTimeRange? initialRange;

  const _CustomRangeDialog({this.initialRange});

  @override
  State<_CustomRangeDialog> createState() => _CustomRangeDialogState();
}

class _CustomRangeDialogState extends State<_CustomRangeDialog> {
  PickerDateRange? range;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRange;
    range = initial == null
        ? null
        : PickerDateRange(initial.start, initial.end);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختيار الفترة المالية'),
      content: SizedBox(
        width: 520,
        height: 380,
        child: SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.range,
          initialSelectedRange: range,
          maxDate: DateTime.now(),
          showNavigationArrow: true,
          onSelectionChanged: (args) {
            final value = args.value;
            if (value is PickerDateRange) setState(() => range = value);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: range?.startDate == null || range?.endDate == null
              ? null
              : () => Navigator.of(context).pop(
                  DateTimeRange(start: range!.startDate!, end: range!.endDate!),
                ),
          child: const Text('تطبيق'),
        ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
