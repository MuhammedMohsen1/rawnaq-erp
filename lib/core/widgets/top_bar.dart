import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../routing/app_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Top bar component with title, search, notifications, and user profile
class TopBar extends StatelessWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Title
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Notifications
          Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                context.go(AppRoutes.notifications);
              },
            ),
          ),
          const SizedBox(width: 16),
          // User profile
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              String userName = 'المستخدم';
              String userRole = 'مدير';

              if (authState is AuthAuthenticated) {
                userName = authState.user.name;
                if (authState.user.isSiteEngineer) {
                  userRole = 'مهندس موقع';
                } else if (authState.user.isManager) {
                  userRole = 'مدير';
                } else if (authState.user.isAdmin) {
                  userRole = 'مدير';
                }
              }

              return Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userRole,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
