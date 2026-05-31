import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../layout/top_bar_title_controller.dart';

/// Top bar component with title, search, notifications, and user profile
class TopBar extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final TopBarAction? action;

  const TopBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                if (showBackButton) ...[
                  _TopBarBackButton(onBackPressed: onBackPressed),
                  const SizedBox(width: 16),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: action == null ? null : _TopBarActionButton(action: action!),
          ),
          // // Notifications
          // Container(
          //   width: 40,
          //   height: 40,
          //   margin: EdgeInsets.symmetric(horizontal: 16),
          //   decoration: BoxDecoration(
          //     color: AppColors.inputBackground,
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(color: AppColors.inputBorder),
          //   ),
          //   child: IconButton(
          //     icon: const Icon(
          //       Icons.notifications_outlined,
          //       color: AppColors.textSecondary,
          //       size: 20,
          //     ),
          //     onPressed: () {
          //       context.go(AppRoutes.notifications);
          //     },
          //   ),
          // ),
          // const SizedBox(width: 16),
          // // User profile
          // BlocBuilder<AuthBloc, AuthState>(
          //   builder: (context, authState) {
          //     String userName = 'المستخدم';
          //     String userRole = 'مدير';

          //     if (authState is AuthAuthenticated) {
          //       userName = authState.user.name;
          //       if (authState.user.isSiteEngineer) {
          //         userRole = 'مهندس موقع';
          //       } else if (authState.user.isManager) {
          //         userRole = 'مدير';
          //       } else if (authState.user.isAdmin) {
          //         userRole = 'مدير';
          //       }
          //     }

          //     return Row(
          //       children: [
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.end,
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Text(
          //               userName,
          //               style: AppTextStyles.bodyMedium.copyWith(
          //                 color: AppColors.textPrimary,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //             Text(
          //               userRole,
          //               style: AppTextStyles.caption.copyWith(
          //                 color: AppColors.textMuted,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}

class _TopBarBackButton extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const _TopBarBackButton({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: IconButton(
        tooltip: 'رجوع',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        icon: const Icon(
          Icons.chevron_left,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onPressed: onBackPressed,
      ),
    );
  }
}

class _TopBarActionButton extends StatelessWidget {
  final TopBarAction action;

  const _TopBarActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: IconButton(
        tooltip: action.tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        icon: Icon(action.icon, color: AppColors.textSecondary, size: 20),
        onPressed: action.onPressed,
      ),
    );
  }
}
