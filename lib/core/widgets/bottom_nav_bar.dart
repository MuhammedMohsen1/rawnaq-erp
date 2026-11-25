import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../routing/app_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'logout_confirmation_dialog.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

enum DashboardSection { home, ongoingProjects }

/// Bottom navigation bar for mobile view.
class AppBottomNavBar extends StatelessWidget {
  final String currentPath;

  /// The active section when the current route is the dashboard.
  ///
  /// This is intentionally separate from [currentPath] because both
  /// the Home and Ongoing Projects sections use AppRoutes.dashboard.
  final DashboardSection dashboardSection;

  /// Notifies the parent when the dashboard section changes.
  final ValueChanged<DashboardSection>? onDashboardSectionChanged;

  const AppBottomNavBar({
    super.key,
    required this.currentPath,
    this.dashboardSection = DashboardSection.home,
    this.onDashboardSectionChanged,
  });

  // ---------------------------------------------------------------------------
  // Selected index
  // ---------------------------------------------------------------------------

  int _getSelectedIndex(
    bool isSiteEngineer,
    bool isDesigner, {
    bool hasSitePricing = false,
  }) {
    // -------------------------------------------------------------------------
    // Site Engineer only
    // -------------------------------------------------------------------------

    if (isSiteEngineer) {
      if (currentPath == AppRoutes.dashboard) {
        return 1;
      }

      if (currentPath == AppRoutes.siteEngineerPricingProjects) {
        return 2;
      }

      if (currentPath == AppRoutes.tasks) {
        return 3;
      }

      if (currentPath == AppRoutes.settings) {
        return 4;
      }

      return 0;
    }

    // -------------------------------------------------------------------------
    // Designer only
    // -------------------------------------------------------------------------

    if (isDesigner) {
      if (currentPath == AppRoutes.projects ||
          currentPath == AppRoutes.dashboard) {
        return 0;
      }

      if (currentPath == AppRoutes.tasks) {
        return 1;
      }

      if (currentPath == AppRoutes.gantt) {
        return 2;
      }

      return 0;
    }

    // -------------------------------------------------------------------------
    // Admin / Manager
    // -------------------------------------------------------------------------

    if (currentPath == AppRoutes.dashboard) {
      return 0;
    }

    if (currentPath == AppRoutes.projects) {
      return 1;
    }

    if (hasSitePricing &&
        currentPath == AppRoutes.siteEngineerPricingProjects) {
      return 2;
    }

    if (currentPath == AppRoutes.tasks) {
      return hasSitePricing ? 3 : 2;
    }

    if (currentPath == AppRoutes.gantt) {
      return hasSitePricing ? 4 : 3;
    }

    if (currentPath == AppRoutes.settings) {
      return hasSitePricing ? 5 : 4;
    }

    return 0;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState is AuthAuthenticated;

        final isSiteEngineer = isAuthenticated && authState.user.isSiteEngineer;

        final isDesigner = isAuthenticated && authState.user.isDesigner;

        final isAdminOrManager =
            isAuthenticated &&
            (authState.user.isAdmin || authState.user.isManager);

        final useDesignerMenu =
            isDesigner && !isSiteEngineer && !isAdminOrManager;

        final useSiteOnlyMenu =
            isSiteEngineer && !isDesigner && !isAdminOrManager;

        final useSpecialistComboMenu =
            isSiteEngineer && isDesigner && !isAdminOrManager;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).sidebarBackground,
            border: Border(
              top: BorderSide(color: AppColors.of(context).border, width: 1),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: useSiteOnlyMenu
                    ? _buildSiteOnlyMenu(context)
                    : useDesignerMenu
                    ? _buildDesignerMenu(context)
                    : useSpecialistComboMenu
                    ? _buildSpecialistComboMenu(context)
                    : _buildAdminManagerMenu(context, isSiteEngineer),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Site Engineer only menu
  // ---------------------------------------------------------------------------

  List<Widget> _buildSiteOnlyMenu(BuildContext context) {
    return [
      _buildNavItem(
        context: context,
        icon: Icons.edit_note_outlined,
        activeIcon: Icons.edit_note,
        label: 'التنفيذ',
        path: AppRoutes.dashboard,
        index: 1,
        isSiteEngineer: true,
        onTap: () {
          _changeDashboardSection(context, DashboardSection.ongoingProjects);
        },
      ),

      _buildNavItem(
        context: context,
        icon: Icons.edit_note_outlined,
        activeIcon: Icons.edit_note,
        label: 'التسعير',
        path: AppRoutes.siteEngineerPricingProjects,
        index: 2,
        isSiteEngineer: true,
      ),

      _buildNavItem(
        context: context,
        icon: Icons.check_circle_outline,
        activeIcon: Icons.check_circle,
        label: 'مهامي',
        path: AppRoutes.tasks,
        index: 3,
        isSiteEngineer: true,
      ),

      _buildNavItem(
        context: context,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'الإعدادات',
        path: AppRoutes.settings,
        index: 4,
        isSiteEngineer: true,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Designer only menu
  // ---------------------------------------------------------------------------

  List<Widget> _buildDesignerMenu(BuildContext context) {
    return [
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

      _buildNavItem(
        context: context,
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'جدول المهام',
        path: AppRoutes.gantt,
        index: 2,
        isSiteEngineer: false,
        isDesigner: true,
      ),

      _buildLogoutItem(context),
    ];
  }

  // ---------------------------------------------------------------------------
  // Site Engineer + Designer menu
  // ---------------------------------------------------------------------------

  List<Widget> _buildSpecialistComboMenu(BuildContext context) {
    return [
      _buildNavItem(
        context: context,
        icon: Icons.design_services_outlined,
        activeIcon: Icons.design_services,
        label: 'التصميم',
        path: AppRoutes.projects,
        index: 1,
        isSiteEngineer: false,
        isDesigner: false,
      ),

      _buildNavItem(
        context: context,
        icon: Icons.rocket_launch_outlined,
        activeIcon: Icons.rocket_launch,
        label: 'التنفيذ',
        path: AppRoutes.dashboard,
        index: 0,
        isSiteEngineer: false,
        isDesigner: false,
        onTap: () {
          _changeDashboardSection(context, DashboardSection.ongoingProjects);
        },
      ),

      _buildNavItem(
        context: context,
        icon: Icons.edit_note_outlined,
        activeIcon: Icons.edit_note,
        label: 'التسعير',
        path: AppRoutes.siteEngineerPricingProjects,
        index: 2,
        isSiteEngineer: false,
      ),

      _buildNavItem(
        context: context,
        icon: Icons.check_circle_outline,
        activeIcon: Icons.check_circle,
        label: 'مهامي',
        path: AppRoutes.tasks,
        index: 3,
        isSiteEngineer: false,
      ),

      _buildNavItem(
        context: context,
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'جدول المهام',
        path: AppRoutes.gantt,
        index: 4,
        isSiteEngineer: false,
      ),

      _buildNavItem(
        context: context,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'الإعدادات',
        path: AppRoutes.settings,
        index: 5,
        isSiteEngineer: false,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Admin / Manager menu
  // ---------------------------------------------------------------------------

  List<Widget> _buildAdminManagerMenu(
    BuildContext context,
    bool isSiteEngineer,
  ) {
    return [
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

      if (isSiteEngineer)
        _buildNavItem(
          context: context,
          icon: Icons.edit_note_outlined,
          activeIcon: Icons.edit_note,
          label: 'التسعير',
          path: AppRoutes.siteEngineerPricingProjects,
          index: 2,
          isSiteEngineer: false,
          isDesigner: false,
        ),

      _buildNavItem(
        context: context,
        icon: Icons.check_circle_outline,
        activeIcon: Icons.check_circle,
        label: 'مهامي',
        path: AppRoutes.tasks,
        index: isSiteEngineer ? 3 : 2,
        isSiteEngineer: false,
        isDesigner: false,
      ),

      _buildNavItem(
        context: context,
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'جدول المهام',
        path: AppRoutes.gantt,
        index: isSiteEngineer ? 4 : 3,
        isSiteEngineer: false,
        isDesigner: false,
      ),

      _buildNavItem(
        context: context,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'الإعدادات',
        path: AppRoutes.settings,
        index: isSiteEngineer ? 5 : 4,
        isSiteEngineer: false,
        isDesigner: false,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Dashboard section handling
  // ---------------------------------------------------------------------------

  void _changeDashboardSection(BuildContext context, DashboardSection section) {
    onDashboardSectionChanged?.call(section);

    if (currentPath != AppRoutes.dashboard) {
      context.go(AppRoutes.dashboard);
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation item
  // ---------------------------------------------------------------------------

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String path,
    required int index,
    required bool isSiteEngineer,
    bool isDesigner = false,
    VoidCallback? onTap,
  }) {
    final authState = context.read<AuthBloc>().state;

    final hasSitePricing =
        authState is AuthAuthenticated &&
        authState.user.isSiteEngineer &&
        (authState.user.isDesigner ||
            authState.user.isAdmin ||
            authState.user.isManager);

    final selectedIndex = _getSelectedIndex(
      isSiteEngineer,
      isDesigner,
      hasSitePricing: hasSitePricing,
    );

    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        if (isSelected) {
          return;
        }

        if (onTap != null) {
          onTap();
        } else {
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
              color: isSelected
                  ? AppColors.of(context).primary
                  : AppColors.of(context).textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              ArabicNumberTransformer.transform(label),
              style: TextStyle(
                color: isSelected
                    ? AppColors.of(context).primary
                    : AppColors.of(context).textMuted,
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

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

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
