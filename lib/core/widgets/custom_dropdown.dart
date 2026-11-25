import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final void Function(T?)? onSaved;
  final bool enabled;
  final bool required;
  final Widget? prefixIcon;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final String? helperText;

  const CustomDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.required = false,
    this.prefixIcon,
    this.fillColor,
    this.borderRadius,
    this.labelStyle,
    this.hintStyle,
    this.contentPadding,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style:
                  labelStyle ??
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.of(context).textPrimary,
                  ),
              children: [
                if (required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.of(context).error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          onSaved: onSaved,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                hintStyle ??
                TextStyle(
                  fontSize: 16,
                  color: AppColors.of(context).textSecondary,
                ),
            helperText: helperText,
            filled: true,
            fillColor: fillColor ?? AppColors.of(context).inputBackground,
            prefixIcon: prefixIcon,
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.of(context).border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.of(context).border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.of(context).primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.of(context).error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.of(context).error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.of(context).lightGrey),
            ),
          ),
          dropdownColor: AppColors.of(context).cardBackground,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.of(context).textPrimary,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}
