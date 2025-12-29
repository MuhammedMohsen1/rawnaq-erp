import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../routing/app_router.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/top_bar.dart';

/// Main layout with responsive navigation
/// - Desktop (>= 768px): Sidebar on the left
/// - Mobile (< 768px): Bottom navigation bar
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          // Desktop layout with sidebar on the left
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Row(
              children: [
                // Sidebar (on the left)
                _Sidebar(currentPath: currentPath),
                // Content area with top bar
                Expanded(
                  child: Column(
                    children: [
                      TopBar(
                        title: _getPageTitle(currentPath),
                        searchHint: 'ابحث عن المشاريع والمهام...',
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile layout with bottom navigation
          return Scaffold(
            backgroundColor: AppColors.sidebarBackground,
            body: child,
            bottomNavigationBar: AppBottomNavBar(currentPath: currentPath),
          );
        }
      },
    );
  }

  String _getPageTitle(String currentPath) {
    if (currentPath == AppRoutes.dashboard) return 'نظرة عامة';
    if (currentPath == AppRoutes.projects) return 'المشاريع';
    if (currentPath == AppRoutes.gantt) return 'مخطط جانت';
    if (currentPath == AppRoutes.settings) return 'الإعدادات';
    if (currentPath == '/financial') return 'المالية';
    if (currentPath == '/team') return 'الفريق';
    return 'نظرة عامة';
  }
}

class _Sidebar extends StatelessWidget {
  final String currentPath;

  const _Sidebar({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Logo/Company section
          _buildHeader(context),

          const SizedBox(height: 24),

          // Navigation items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'لوحة التحكم',
                    path: AppRoutes.dashboard,
                    isActive: currentPath == AppRoutes.dashboard,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.folder_outlined,
                    activeIcon: Icons.folder,
                    label: 'المشاريع',
                    path: AppRoutes.projects,
                    isActive: currentPath == AppRoutes.projects,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart,
                    label: 'مخطط جانت',
                    path: AppRoutes.gantt,
                    isActive: currentPath == AppRoutes.gantt,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.account_balance_outlined,
                    activeIcon: Icons.account_balance,
                    label: 'المالية',
                    path: '/financial',
                    isActive: currentPath == '/financial',
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.people_outlined,
                    activeIcon: Icons.people,
                    label: 'الفريق',
                    path: '/team',
                    isActive: currentPath == '/team',
                  ),
                ],
              ),
            ),
          ),

          // Bottom section
          const Divider(color: AppColors.divider, height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'الإعدادات',
                  path: AppRoutes.settings,
                  isActive: currentPath == AppRoutes.settings,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.help_outline,
                  activeIcon: Icons.help,
                  label: 'المساعدة',
                  path: '/help',
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          // Logo/Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF22C55E), // Green
                  Color(0xFF3B82F6), // Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.business,
                color: AppColors.scaffoldBackground,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Company info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rawnaq',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'نظام إدارة المشاريع',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String path,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isActive && path != '/help') {
              context.go(path);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: isActive
                        ? AppTextStyles.navItemActive.copyWith(
                            color: AppColors.primary,
                          )
                        : AppTextStyles.navItem,
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrapper for pages that use the main layout
class MainLayoutPage extends StatelessWidget {
  final Widget child;
  final Widget? floatingActionButton;

  const MainLayoutPage({
    super.key,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sidebarBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.sidebarBackground,
        child: child,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
