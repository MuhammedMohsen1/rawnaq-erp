import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AddIncomeRowContent extends StatelessWidget {
  final bool isCompact;
  final bool isSubmitting;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final DateTime selectedDate;
  final List<PlatformFile> attachments;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final VoidCallback onPickAttachments;
  final ValueChanged<int> onRemoveAttachment;
  final ValueChanged<DateTime> onDateChanged;

  const AddIncomeRowContent({
    super.key,
    required this.isCompact,
    required this.isSubmitting,
    required this.descriptionController,
    required this.amountController,
    required this.selectedDate,
    required this.attachments,
    required this.onCancel,
    required this.onSubmit,
    required this.onPickAttachments,
    required this.onRemoveAttachment,
    required this.onDateChanged,
  });

  Widget _datePicker(BuildContext context, {required EdgeInsets padding}) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onDateChanged(date);
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 4),
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentsPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: isSubmitting ? null : onPickAttachments,
          icon: const Icon(Icons.attach_file, size: 16),
          label: Text(
            attachments.isEmpty ? 'إرفاق صورة' : '${attachments.length} مرفق',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: attachments.asMap().entries.map((entry) {
              final file = entry.value;
              return Container(
                constraints: BoxConstraints(maxWidth: isCompact ? 180 : 140),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: isSubmitting
                          ? null
                          : () => onRemoveAttachment(entry.key),
                      child: const Icon(
                        Icons.close,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _compact() {
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
          controller: amountController,
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
        Builder(
          builder: (context) => _datePicker(
            context,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            hintText: 'وصف الإيراد (مثال: دفعة العميل)',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        _attachmentsPicker(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
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

  Widget _wide() {
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
            controller: descriptionController,
            decoration: const InputDecoration(
              hintText: 'وصف الإيراد (مثال: دفعة العميل)',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 130,
          child: Builder(
            builder: (context) => _datePicker(
              context,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: TextField(
            controller: amountController,
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
        SizedBox(width: 150, child: _attachmentsPicker()),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close, color: AppColors.error),
              tooltip: 'إلغاء',
            ),
            IconButton(
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
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

  @override
  Widget build(BuildContext context) {
    return isCompact ? _compact() : _wide();
  }
}
