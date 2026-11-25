import 'package:rawnaq/core/utils/arabic_number_input_formatter.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

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
              text: ArabicNumberTransformer.transformNullable(widget.label!),
              style:
                  widget.labelStyle ??
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.of(context).textPrimary,
                  ),
              children: [
                if (widget.required)
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
        TextFormField(
          inputFormatters: const [ArabicNumberInputFormatter()],
          controller: _controller,
          enabled: widget.enabled,
          validator: widget.validator,
          onSaved: widget.onSaved,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Enter image URL',
            hintStyle:
                widget.hintStyle ??
                TextStyle(
                  fontSize: 16,
                  color: AppColors.of(context).textSecondary,
                ),
            prefixIcon: Icon(
              Icons.image,
              color: AppColors.of(context).textSecondary,
            ),
            fillColor:
                widget.fillColor ?? AppColors.of(context).inputBackground,
            filled: true,
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.of(context).border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.of(context).border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.of(context).primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.of(context).error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.of(context).error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.of(context).textSecondary,
                width: 1,
              ),
            ),
          ),
        ),
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              ArabicNumberTransformer.transform(widget.helperText!),
              style: TextStyle(
                color: AppColors.of(context).textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
