import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialogKeyboardActions extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSubmit;
  final VoidCallback? onClose;
  final bool enabled;

  const DialogKeyboardActions({
    super.key,
    required this.child,
    this.onSubmit,
    this.onClose,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        if (onSubmit != null) ...{
          const SingleActivator(LogicalKeyboardKey.enter): onSubmit!,
          const SingleActivator(LogicalKeyboardKey.numpadEnter): onSubmit!,
        },
        if (onClose != null)
          const SingleActivator(LogicalKeyboardKey.escape): onClose!,
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
