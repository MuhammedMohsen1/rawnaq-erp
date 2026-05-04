import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ExecutionHeader extends StatelessWidget {
  final String projectName;
  final VoidCallback? onOpenPastPricing;
  final VoidCallback? onMarkComplete;

  const ExecutionHeader({
    super.key,
    required this.projectName,
    this.onOpenPastPricing,
    this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectName,
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
              ),
              // const SizedBox(height: 4),

              // Text(
              //   'إدارة مصروفات الموقع، تتبع الدفعات، ومراقبة التدفق النقدي',
              //   style: AppTextStyles.bodyMedium.copyWith(
              //     color: AppColors.textSecondary,
              //   ),
              // ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onMarkComplete != null) ...[
              ElevatedButton.icon(
                onPressed: onMarkComplete,
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: const Text('إكمال المشروع'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusCompleted,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 10),
            ],
            if (onOpenPastPricing != null)
              OutlinedButton.icon(
                onPressed: onOpenPastPricing,
                icon: const Icon(Icons.history, size: 18),
                label: const Text('التسعير'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
