import 'package:flutter/material.dart';

enum ToastTone { success, error, warning, info }

class AppToast {
  const AppToast._();

  static SnackBar build({
    required ToastTone tone,
    required Widget content,
    Duration? duration,
    EdgeInsetsGeometry? margin,
    SnackBarAction? action,
  }) {
    final (background, foreground, icon) = switch (tone) {
      ToastTone.success => (
        const Color(0xFFE7F6EB),
        const Color(0xFF14532D),
        Icons.check_circle_outline,
      ),
      ToastTone.error => (
        const Color(0xFFFDEBEC),
        const Color(0xFF991B1B),
        Icons.error_outline,
      ),
      ToastTone.warning => (
        const Color(0xFFFFF2D4),
        const Color(0xFF78350F),
        Icons.warning_amber_rounded,
      ),
      ToastTone.info => (null, null, Icons.info_outline),
    };

    if (content is Text && foreground != null && content.style != null) {
      final text = content;
      content = Text(
        text.data ?? '',
        style: text.style!.copyWith(color: foreground),
        textDirection: text.textDirection,
      );
    }

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 2,
      backgroundColor: background,
      duration: duration ?? const Duration(seconds: 4),
      margin: margin,
      action: action == null || foreground == null
          ? action
          : SnackBarAction(
              label: action.label,
              onPressed: action.onPressed,
              textColor: foreground,
            ),
      content: Row(
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: foreground),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
