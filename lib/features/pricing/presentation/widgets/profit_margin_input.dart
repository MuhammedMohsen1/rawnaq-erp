import 'package:rawnaq/core/utils/arabic_number_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Input widget for profit margin percentage
class ProfitMarginInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool compact;
  final bool fillHeight;
  final VoidCallback? onEditingComplete;

  const ProfitMarginInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
    this.compact = false,
    this.fillHeight = false,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return TextField(
        controller: controller,
        enabled: enabled,
        expands: fillHeight,
        minLines: fillHeight ? null : 1,
        maxLines: fillHeight ? null : 1,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          const ArabicNumberInputFormatter(),
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        style: AppTextStyles.of(context).bodyMedium.copyWith(
          color: AppColors.of(context).textPrimary,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: 'نسبة الربح',
          labelStyle: AppTextStyles.of(context).bodyMedium.copyWith(
            color: AppColors.of(context).textSecondary,
            fontWeight: FontWeight.w600,
          ),
          hintText: '0.00',
          hintStyle: TextStyle(
            color: AppColors.of(context).textMuted.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: AppColors.of(context).inputBackground,
          isDense: !fillHeight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.of(context).border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.of(context).primary,
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.of(context).border),
          ),
          suffixText: '%',
          suffixStyle: AppTextStyles.of(context).bodySmall.copyWith(
            color: AppColors.of(context).textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).tableRowHover,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: fillHeight ? 1 : 0,
            child: TextField(
              controller: controller,
              enabled: enabled,
              expands: fillHeight,
              minLines: fillHeight ? null : 1,
              maxLines: fillHeight ? null : 1,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                const ArabicNumberInputFormatter(),
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: AppTextStyles.of(context).bodyLarge.copyWith(
                color: AppColors.of(context).textPrimary,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'نسبة الربح',
                labelStyle: AppTextStyles.of(context).bodyMedium.copyWith(
                  color: AppColors.of(context).textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: AppColors.of(context).textMuted.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppColors.of(context).inputBackground,
                isDense: !fillHeight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.of(context).border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.of(context).border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.of(context).primary,
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.of(context).border),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.percent,
                    color: AppColors.of(context).textMuted,
                    size: 20,
                  ),
                ),
              ),
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
            ),
          ),
          if (!fillHeight) ...[
            const SizedBox(height: 8),
            Text(
              'سيتم حساب السعر النهائي تلقائياً بناءً على التكلفة ونسبة الربح',
              style: AppTextStyles.of(context).caption.copyWith(
                color: AppColors.of(context).textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
