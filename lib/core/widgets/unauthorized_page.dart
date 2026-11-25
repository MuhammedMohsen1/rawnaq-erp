import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../routing/app_router.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.of(context).error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: AppColors.of(context).error,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'غير مصرح',
                style: AppTextStyles.of(
                  context,
                ).h2.copyWith(color: AppColors.of(context).error),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'ليس لديك صلاحية للوصول إلى هذه الصفحة',
                style: AppTextStyles.of(context).bodyLarge.copyWith(
                  color: AppColors.of(context).textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Action Buttons
              OutlinedButton.icon(
                onPressed: () {
                  context.go(AppRoutes.dashboard);
                },
                icon: const Icon(Icons.dashboard),
                label: const Text('لوحة القيادة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.of(context).primary,
                  side: BorderSide(color: AppColors.of(context).primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
