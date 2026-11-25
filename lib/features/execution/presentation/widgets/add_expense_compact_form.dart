import 'package:rawnaq/core/utils/arabic_number_input_formatter.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AddExpenseCompactForm extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController unitCostController;
  final TextEditingController quantityController;
  final TextEditingController nameController;
  final bool isSubmitting;
  final bool isReturnedExpense;
  final bool showTotalAmount;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final ValueChanged<bool> onReturnedExpenseChanged;

  const AddExpenseCompactForm({
    super.key,
    required this.amountController,
    required this.unitCostController,
    required this.quantityController,
    required this.nameController,
    required this.isSubmitting,
    required this.isReturnedExpense,
    required this.showTotalAmount,
    required this.onCancel,
    required this.onSubmit,
    required this.onReturnedExpenseChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.of(context).error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward,
                color: AppColors.of(context).error,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text('إضافة مصروف', style: AppTextStyles.of(context).tableCellBold),
          ],
        ),
        const SizedBox(height: 12),
        if (showTotalAmount)
          TextField(
            inputFormatters: const [ArabicNumberInputFormatter()],
            controller: amountController,
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
                  inputFormatters: const [ArabicNumberInputFormatter()],
                  controller: unitCostController,
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
                  inputFormatters: const [ArabicNumberInputFormatter()],
                  controller: quantityController,
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
          inputFormatters: const [ArabicNumberInputFormatter()],
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'اسم البند',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: isReturnedExpense,
          onChanged: (value) => onReturnedExpenseChanged(value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'مرتجع مصروف',
            style: AppTextStyles.of(
              context,
            ).tableCellBold.copyWith(color: AppColors.of(context).success),
          ),
          subtitle: Text(
            'استخدمها عند إرجاع بقايا خامات مثل الخشب',
            style: AppTextStyles.of(context).caption,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onCancel,
              icon: Icon(Icons.close, color: AppColors.of(context).error),
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
                  : Icon(Icons.check, color: AppColors.of(context).success),
              tooltip: 'حفظ',
            ),
          ],
        ),
      ],
    );
  }
}
