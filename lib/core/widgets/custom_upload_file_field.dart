import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomUploadFileField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? value;
  final TextEditingController? controller;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool enabled;
  final bool required;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final String? helperText;

  const CustomUploadFileField({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.controller,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.required = false,
    this.fillColor,
    this.borderRadius,
    this.labelStyle,
    this.hintStyle,
    this.contentPadding,
    this.helperText,
  });

  @override
  State<CustomUploadFileField> createState() => _CustomUploadFileFieldState();
}

class _CustomUploadFileFieldState extends State<CustomUploadFileField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style:
                  widget.labelStyle ??
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
              children: [
                if (widget.required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _controller,
          enabled: widget.enabled,
          validator: widget.validator,
          onSaved: widget.onSaved,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Enter image URL',
            hintStyle:
                widget.hintStyle ??
                const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.image, color: AppColors.textSecondary),
            fillColor: widget.fillColor ?? AppColors.white,
            filled: true,
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.textSecondary,
                width: 1,
              ),
            ),
          ),
        ),
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              widget.helperText!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
