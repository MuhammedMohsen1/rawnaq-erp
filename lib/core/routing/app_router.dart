import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/projects/presentation/pages/projects_list_page.dart';
import '../../features/projects/presentation/bloc/projects_bloc.dart';
import '../../features/projects/presentation/bloc/projects_event.dart';
import '../../features/projects/presentation/bloc/projects_state.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/domain/repositories/projects_repository.dart';
import '../../features/gantt/presentation/pages/gantt_chart_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../widgets/error_page.dart';
import '../widgets/unauthorized_page.dart';
import '../layout/main_layout.dart';
import '../storage/storage_service.dart';
import '../di/injection_container.dart';
import 'custom_page_transitions.dart';

class AppRoutes {
  static const String login = '/login';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';
  static const String unauthorized = '/unauthorized';

  // Projects
  static const String projects = '/projects';

  // Gantt Chart
  static const String gantt = '/gantt';

  // Tasks
  static const String tasks = '/tasks';

  // Reports
  static const String reports = '/reports';

  // Settings
  static const String settings = '/settings';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    navigatorKey: getIt<GlobalKey<NavigatorState>>(),
    redirect: (context, state) async {
      final storageService = getIt<StorageService>();
      final token = await storageService.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      final currentPath = state.uri.toString();
      final isOnAuthPage = currentPath == AppRoutes.login ||
          currentPath == AppRoutes.resetPassword;

      // If not logged in and not on auth page, redirect to login
      if (!isLoggedIn && !isOnAuthPage) {
        return AppRoutes.login;
      }

      // If logged in and on auth page, redirect to dashboard
      if (isLoggedIn && isOnAuthPage) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // Auth routes (no layout)
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            FadePageTransition(key: state.pageKey, child: const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (context, state) => FadePageTransition(
          key: state.pageKey,
          child: const ResetPasswordPage(),
        ),
      ),

      // Unauthorized page (no layout)
      GoRoute(
        path: AppRoutes.unauthorized,
        pageBuilder: (context, state) => FadePageTransition(
          key: state.pageKey,
          child: const UnauthorizedPage(),
        ),
      ),

      // Main app shell with persistent sidebar
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: const _DashboardPage(),
            ),
          ),

          // Projects
          GoRoute(
            path: AppRoutes.projects,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => ProjectsBloc(
                  repository: ProjectsRepositoryImpl(),
                )..add(const LoadProjects()),
                child: const ProjectsListPage(),
              ),
            ),
          ),

          // Gantt Chart
          GoRoute(
            path: AppRoutes.gantt,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: const GanttChartPage(),
            ),
          ),

          // Tasks (placeholder)
          GoRoute(
            path: AppRoutes.tasks,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: const _PlaceholderPage(
                title: 'المهام',
                icon: Icons.check_circle_outline,
                subtitle: 'قريباً - إدارة المهام والأنشطة',
              ),
            ),
          ),

          // Reports (placeholder)
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: const _PlaceholderPage(
                title: 'التقارير',
                icon: Icons.bar_chart_outlined,
                subtitle: 'قريباً - تقارير وإحصائيات المشاريع',
              ),
            ),
          ),

          // Settings
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) =>
        FadePageTransition(key: state.pageKey, child: const ErrorPage()),
  );
}

// Dashboard page with statistics overview
class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectsBloc(
        repository: ProjectsRepositoryImpl(),
      )..add(const LoadProjects()),
      child: BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة القيادة',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Stats cards
                if (state is ProjectsLoaded && state.statistics != null)
                  _buildStatsCards(context, state.statistics!),

                const SizedBox(height: 32),

                // Quick actions
                Text(
                  'إجراءات سريعة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.add_circle_outline,
                      label: 'مشروع جديد',
                      onTap: () => context.go(AppRoutes.projects),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.folder_open,
                      label: 'عرض المشاريع',
                      onTap: () => context.go(AppRoutes.projects),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.assignment,
                      label: 'المهام',
                      onTap: () => context.go(AppRoutes.tasks),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.analytics,
                      label: 'التقارير',
                      onTap: () => context.go(AppRoutes.reports),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, ProjectStatistics stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'إجمالي المشاريع',
            value: stats.total.toString(),
            icon: Icons.folder,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'مشاريع نشطة',
            value: stats.active.toString(),
            icon: Icons.play_circle,
            color: const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'مشاريع مكتملة',
            value: stats.completed.toString(),
            icon: Icons.check_circle,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'مشاريع متأخرة',
            value: stats.delayed.toString(),
            icon: Icons.warning,
            color: const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF8B949E),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF238636), size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder page for features not yet implemented
class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;

  const _PlaceholderPage({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Icon(
              icon,
              size: 64,
              color: const Color(0xFF8B949E),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF8B949E),
                ),
          ),
        ],
      ),
    );
  }
}
