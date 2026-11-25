import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class ProjectsConfirmActionDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const ProjectsConfirmActionDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 34),
            const SizedBox(height: 12),
            Text(ArabicNumberTransformer.transform(title)),
            const SizedBox(height: 12),
            Text(ArabicNumberTransformer.transform(message)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.of(context).error,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(
                      ArabicNumberTransformer.transform(confirmLabel),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
