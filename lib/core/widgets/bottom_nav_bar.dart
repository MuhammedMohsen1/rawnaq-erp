import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../routing/app_router.dart';

/// Bottom navigation bar for mobile view
class AppBottomNavBar extends StatelessWidget {
  final String currentPath;

  const AppBottomNavBar({super.key, required this.currentPath});

  int _getSelectedIndex() {
    if (currentPath == AppRoutes.dashboard) return 0;
    if (currentPath == AppRoutes.projects) return 1;
    if (currentPath == AppRoutes.gantt) return 2;
    if (currentPath == AppRoutes.settings) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'لوحة القيادة',
                path: AppRoutes.dashboard,
                index: 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.folder_outlined,
                activeIcon: Icons.folder,
                label: 'المشاريع',
                path: AppRoutes.projects,
                index: 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'مخطط جانت',
                path: AppRoutes.gantt,
                index: 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'الإعدادات',
                path: AppRoutes.settings,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String path,
    required int index,
  }) {
    final isSelected = _getSelectedIndex() == index;

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

