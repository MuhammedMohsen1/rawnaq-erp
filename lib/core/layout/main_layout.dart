import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../routing/app_router.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/top_bar.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/projects/presentation/bloc/projects_bloc.dart';
import '../../features/projects/presentation/bloc/projects_state.dart';

/// Main layout with responsive navigation
/// - Desktop (>= 768px): Sidebar on the left
/// - Mobile (< 768px): Bottom navigation bar
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final routeState = GoRouterState.of(context);

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
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TopBar(
                        title: _getPageTitle(context, currentPath, routeState),
                        searchHint: 'ابحث عن المشاريع والمهام...',
                      ),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: child,
                        ),
                      ),
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

  String _getPageTitle(
    BuildContext context,
    String currentPath,
    GoRouterState routeState,
  ) {
    if (currentPath == AppRoutes.dashboard) return 'نظرة عامة';
    if (currentPath == AppRoutes.projects) return 'المشاريع';
    if (currentPath == AppRoutes.gantt) return 'مخطط جانت';
    if (currentPath == AppRoutes.settings) return 'الإعدادات';
    if (currentPath == AppRoutes.notifications) return 'الإشعارات';
    if (currentPath == AppRoutes.reminders) return 'التذكيرات';
    if (currentPath == '/financial') return 'المالية';
    if (currentPath == '/team') return 'الفريق';

    // Check if it's a project details page
    final projectId = routeState.pathParameters['projectId'];
    if (projectId != null && currentPath.startsWith('/projects/')) {
      // Try to get project name from bloc
      try {
        final projectsState = context.read<ProjectsBloc>().state;
        if (projectsState is ProjectsLoaded) {
          final project = projectsState.projects.firstWhere(
            (p) => p.id == projectId,
            orElse: () => projectsState.projects.first,
          );
          if (project.id == projectId) {
            return project.name;
          }
        }
      } catch (e) {
        // Fallback to generic title
      }
      return 'تفاصيل المشروع';
    }

    // Check if it's a pricing page
    if (projectId != null && currentPath.startsWith('/pricing/')) {
      try {
        final projectsState = context.read<ProjectsBloc>().state;
        if (projectsState is ProjectsLoaded) {
          final project = projectsState.projects.firstWhere(
            (p) => p.id == projectId,
            orElse: () => projectsState.projects.first,
          );
          if (project.id == projectId) {
            return '${project.name} - التسعير';
          }
        }
      } catch (e) {
        // Fallback to generic title
      }
      return 'التسعير';
    }

    return 'نظرة عامة';
  }
}

class _Sidebar extends StatefulWidget {
  final String currentPath;

  const _Sidebar({required this.currentPath});

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      width: _isCollapsed ? 100 : 260,
      decoration: const BoxDecoration(
        color: Color(0xFF1C2128),
        border: Border(left: BorderSide(color: Color(0xFF312F31), width: 1)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isCollapsed
            ? SizedBox(
                key: const ValueKey('collapsed'),
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildCollapsedContent(),
                ),
              )
            : SizedBox(
                key: const ValueKey('expanded'),
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildExpandedContent(),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildCollapsedContent() {
    return [
      // Logo/Company section
      Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Avatar
            Container(
              width: 51,
              height: 51,
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
          ],
        ),
      ),

      const SizedBox(height: 24),

      // Navigation items
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isSiteEngineer =
                  authState is AuthAuthenticated &&
                  authState.user.isSiteEngineer;

              if (isSiteEngineer) {
                return Column(
                  children: [
                    _buildCollapsedNavItem(
                      context: context,
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      path: AppRoutes.dashboard,
                      isActive: widget.currentPath == AppRoutes.dashboard,
                    ),
                    _buildCollapsedNavItem(
                      context: context,
                      icon: Icons.notifications_active_outlined,
                      activeIcon: Icons.notifications_active,
                      path: AppRoutes.reminders,
                      isActive: widget.currentPath == AppRoutes.reminders,
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildCollapsedNavItem(
                      context: context,
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      path: AppRoutes.dashboard,
                      isActive: widget.currentPath == AppRoutes.dashboard,
                    ),
                    _buildCollapsedNavItem(
                      context: context,
                      icon: Icons.folder_outlined,
                      activeIcon: Icons.folder,
                      path: AppRoutes.projects,
                      isActive: widget.currentPath == AppRoutes.projects,
                    ),
                    _buildCollapsedNavItem(
                      context: context,
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      path: AppRoutes.gantt,
                      isActive: widget.currentPath == AppRoutes.gantt,
                    ),
                    _buildCollapsedNavItem(
                      context: context,
                      icon: Icons.account_balance_outlined,
                      activeIcon: Icons.account_balance,
                      path: '/financial',
                      isActive: widget.currentPath == '/financial',
                    ),
                    _buildCollapsedNavItem(
                      context: context,
                      icon: Icons.people_outlined,
                      activeIcon: Icons.people,
                      path: '/team',
                      isActive: widget.currentPath == '/team',
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),

      // Bottom section
      const Divider(color: AppColors.divider, height: 1),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildCollapsedNavItem(
              context: context,
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              path: AppRoutes.settings,
              isActive: widget.currentPath == AppRoutes.settings,
            ),
            _buildCollapsedNavItem(
              context: context,
              icon: Icons.help_outline,
              activeIcon: Icons.help,
              path: '/help',
              isActive: false,
            ),
            // Toggle button
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.border, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Icon(
                        _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                        key: ValueKey<bool>(_isCollapsed),
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildExpandedContent() {
    return [
      // Logo/Company section
      _buildHeader(context),

      const SizedBox(height: 24),

      // Navigation items
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isSiteEngineer =
                  authState is AuthAuthenticated &&
                  authState.user.isSiteEngineer;

              if (isSiteEngineer) {
                // Site Engineer menu items
                return Column(
                  children: [
                    _buildNavItem(
                      context: context,
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'لوحة التحكم',
                      path: AppRoutes.dashboard,
                      isActive: widget.currentPath == AppRoutes.dashboard,
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.notifications_active_outlined,
                      activeIcon: Icons.notifications_active,
                      label: 'التذكيرات',
                      path: AppRoutes.reminders,
                      isActive: widget.currentPath == AppRoutes.reminders,
                    ),
                  ],
                );
              } else {
                // Manager/Admin menu items
                return Column(
                  children: [
                    _buildNavItem(
                      context: context,
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'لوحة التحكم',
                      path: AppRoutes.dashboard,
                      isActive: widget.currentPath == AppRoutes.dashboard,
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.folder_outlined,
                      activeIcon: Icons.folder,
                      label: 'المشاريع',
                      path: AppRoutes.projects,
                      isActive: widget.currentPath == AppRoutes.projects,
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      label: 'مخطط جانت',
                      path: AppRoutes.gantt,
                      isActive: widget.currentPath == AppRoutes.gantt,
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.account_balance_outlined,
                      activeIcon: Icons.account_balance,
                      label: 'المالية',
                      path: '/financial',
                      isActive: widget.currentPath == '/financial',
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.people_outlined,
                      activeIcon: Icons.people,
                      label: 'الفريق',
                      path: '/team',
                      isActive: widget.currentPath == '/team',
                    ),
                  ],
                );
              }
            },
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
              isActive: widget.currentPath == AppRoutes.settings,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.help_outline,
              activeIcon: Icons.help,
              label: 'المساعدة',
              path: '/help',
              isActive: false,
            ),
            // Toggle button
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.border, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          _isCollapsed
                              ? Icons.chevron_right
                              : Icons.chevron_left,
                          key: ValueKey<bool>(_isCollapsed),
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),

      child: Row(
        mainAxisAlignment: _isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          // Logo/Avatar
          Container(
            width: 51,
            height: 51,
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
          if (!_isCollapsed) ...[
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
        ],
      ),
    );
  }

  Widget _buildCollapsedNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String path,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: Tooltip(
          message: _getNavItemLabel(path),
          child: InkWell(
            onTap: () {
              if (!isActive && path != '/help') {
                context.go(path);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4),
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
              child: Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getNavItemLabel(String path) {
    if (path == AppRoutes.dashboard) return 'لوحة التحكم';
    if (path == AppRoutes.projects) return 'المشاريع';
    if (path == AppRoutes.gantt) return 'مخطط جانت';
    if (path == AppRoutes.settings) return 'الإعدادات';
    if (path == AppRoutes.notifications) return 'الإشعارات';
    if (path == AppRoutes.reminders) return 'التذكيرات';
    if (path == '/financial') return 'المالية';
    if (path == '/team') return 'الفريق';
    if (path == '/help') return 'المساعدة';
    return '';
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
        child: Tooltip(
          message: _isCollapsed ? label : '',
          child: InkWell(
            onTap: () {
              if (!isActive && path != '/help') {
                context.go(path);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: _isCollapsed
                  ? const EdgeInsets.symmetric(horizontal: 4, vertical: 12)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                mainAxisAlignment: _isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    size: 22,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  if (!_isCollapsed) ...[
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
                ],
              ),
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
