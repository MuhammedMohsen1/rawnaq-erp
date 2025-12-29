import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../routing/app_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Bottom navigation bar for mobile view
class AppBottomNavBar extends StatelessWidget {
  final String currentPath;

  const AppBottomNavBar({super.key, required this.currentPath});

  int _getSelectedIndex(bool isSiteEngineer) {
    if (isSiteEngineer) {
      if (currentPath == AppRoutes.dashboard) return 0;
      if (currentPath == AppRoutes.reminders) return 1;
      if (currentPath == AppRoutes.settings) return 2;
      return 0;
    } else {
    if (currentPath == AppRoutes.dashboard) return 0;
    if (currentPath == AppRoutes.projects) return 1;
    if (currentPath == AppRoutes.gantt) return 2;
    if (currentPath == AppRoutes.settings) return 3;
    return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isSiteEngineer = authState is AuthAuthenticated &&
            authState.user.isSiteEngineer;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
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
                          label: 'لوحة التحكم',
                          path: AppRoutes.dashboard,
                          index: 0,
                          isSiteEngineer: true,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.notifications_active_outlined,
                          activeIcon: Icons.notifications_active,
                          label: 'التذكيرات',
                          path: AppRoutes.reminders,
                          index: 1,
                          isSiteEngineer: true,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings,
                          label: 'الإعدادات',
                          path: AppRoutes.settings,
                          index: 2,
                          isSiteEngineer: true,
                        ),
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
              ),
              _buildNavItem(
                context: context,
                icon: Icons.folder_outlined,
                activeIcon: Icons.folder,
                label: 'المشاريع',
                path: AppRoutes.projects,
                index: 1,
                          isSiteEngineer: false,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'مخطط جانت',
                path: AppRoutes.gantt,
                index: 2,
                          isSiteEngineer: false,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'الإعدادات',
                path: AppRoutes.settings,
                index: 3,
                          isSiteEngineer: false,
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
  }) {
    final isSelected = _getSelectedIndex(isSiteEngineer) == index;

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
}

