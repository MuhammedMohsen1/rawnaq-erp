import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../routing/app_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'logout_confirmation_dialog.dart';

/// Bottom navigation bar for mobile view
class AppBottomNavBar extends StatelessWidget {
  final String currentPath;

  const AppBottomNavBar({super.key, required this.currentPath});

  int _getSelectedIndex(bool isSiteEngineer, bool isDesigner) {
    if (isSiteEngineer) {
      if (currentPath == AppRoutes.dashboard) return 0;
      if (currentPath == AppRoutes.siteEngineerPricingProjects) return 1;
      if (currentPath == AppRoutes.tasks) return 2;
      if (currentPath == AppRoutes.settings) return 3;
      return 0;
    } else if (isDesigner) {
      if (currentPath == AppRoutes.projects ||
          currentPath == AppRoutes.dashboard) {
        return 0;
      }
      if (currentPath == AppRoutes.tasks) return 1;
      return 0;
    } else {
      if (currentPath == AppRoutes.dashboard) return 0;
      if (currentPath == AppRoutes.projects) return 1;
      if (currentPath == AppRoutes.tasks) return 2;
      if (currentPath == AppRoutes.gantt) return 3;
      if (currentPath == AppRoutes.settings) return 4;
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isSiteEngineer =
            authState is AuthAuthenticated && authState.user.isSiteEngineer;
        final isDesigner =
            authState is AuthAuthenticated && authState.user.isDesigner;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.sidebarBackground,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: isSiteEngineer
                    ? [
                        // Site Engineer menu items
                        _buildNavItem(
                          context: context,
                          icon: Icons.dashboard_outlined,
                          activeIcon: Icons.dashboard,
                          label: 'التنفيذ',
                          path: AppRoutes.dashboard,
                          index: 0,
                          isSiteEngineer: true,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.edit_note_outlined,
                          activeIcon: Icons.edit_note,
                          label: 'التسعير',
                          path: AppRoutes.siteEngineerPricingProjects,
                          index: 1,
                          isSiteEngineer: true,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.check_circle_outline,
                          activeIcon: Icons.check_circle,
                          label: 'مهامي',
                          path: AppRoutes.tasks,
                          index: 2,
                          isSiteEngineer: true,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings,
                          label: 'الإعدادات',
                          path: AppRoutes.settings,
                          index: 3,
                          isSiteEngineer: true,
                        ),
                      ]
                    : isDesigner
                    ? [
                        _buildNavItem(
                          context: context,
                          icon: Icons.design_services_outlined,
                          activeIcon: Icons.design_services,
                          label: 'التصميم',
                          path: AppRoutes.projects,
                          index: 0,
                          isSiteEngineer: false,
                          isDesigner: true,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.check_circle_outline,
                          activeIcon: Icons.check_circle,
                          label: 'مهامي',
                          path: AppRoutes.tasks,
                          index: 1,
                          isSiteEngineer: false,
                          isDesigner: true,
                        ),
                        _buildLogoutItem(context),
                      ]
                    : [
                        // Manager/Admin menu items
                        _buildNavItem(
                          context: context,
                          icon: Icons.dashboard_outlined,
                          activeIcon: Icons.dashboard,
                          label: 'لوحة القيادة',
                          path: AppRoutes.dashboard,
                          index: 0,
                          isSiteEngineer: false,
                          isDesigner: false,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.folder_outlined,
                          activeIcon: Icons.folder,
                          label: 'المشاريع',
                          path: AppRoutes.projects,
                          index: 1,
                          isSiteEngineer: false,
                          isDesigner: false,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.check_circle_outline,
                          activeIcon: Icons.check_circle,
                          label: 'مهامي',
                          path: AppRoutes.tasks,
                          index: 2,
                          isSiteEngineer: false,
                          isDesigner: false,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.bar_chart_outlined,
                          activeIcon: Icons.bar_chart,
                          label: 'مخطط جانت',
                          path: AppRoutes.gantt,
                          index: 3,
                          isSiteEngineer: false,
                          isDesigner: false,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings,
                          label: 'الإعدادات',
                          path: AppRoutes.settings,
                          index: 4,
                          isSiteEngineer: false,
                          isDesigner: false,
                        ),
                      ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String path,
    required int index,
    required bool isSiteEngineer,
    bool isDesigner = false,
  }) {
    final isSelected = _getSelectedIndex(isSiteEngineer, isDesigner) == index;

    return InkWell(
      onTap: () {
        if (!isSelected) {
          context.go(path);
        }
      },
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return InkWell(
      onTap: () => showLogoutConfirmationDialog(context),
      child: const SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red, size: 24),
            SizedBox(height: 4),
            Text(
              'خروج',
              style: TextStyle(
                color: Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
