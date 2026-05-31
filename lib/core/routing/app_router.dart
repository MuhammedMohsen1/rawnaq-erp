import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/projects/presentation/pages/projects_list_page.dart';
import '../../features/projects/presentation/bloc/projects_bloc.dart';
import '../../features/projects/presentation/bloc/projects_event.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/domain/enums/project_status.dart';
import '../../features/gantt/presentation/pages/gantt_chart_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';
import '../../features/pricing/presentation/pages/under_pricing_page.dart';
import '../../features/execution/presentation/pages/execution_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
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
  static const String siteEngineerPricingProjects = '/projects/site-pricing';
  static const String archivedProjects = '/projects/archived';
  static const String completedProjects = '/projects/completed';

  // Gantt Chart
  static const String gantt = '/gantt';

  // Tasks
  static const String tasks = '/tasks';

  // Reports
  static const String reports = '/reports';

  // Settings
  static const String settings = '/settings';

  // Notifications
  static const String notifications = '/notifications';

  // Reminders
  static const String reminders = '/reminders';

  // Pricing
  static String pricing(
    String projectId, {
    bool readOnly = false,
    bool hideFinancials = false,
  }) {
    final queryParameters = <String, String>{
      if (readOnly) 'readOnly': 'true',
      if (hideFinancials) 'hideFinancials': 'true',
    };
    final query = Uri(queryParameters: queryParameters).query;
    return query.isEmpty ? '/pricing/$projectId' : '/pricing/$projectId?$query';
  }

  // Execution
  static String execution(String projectId) => '/execution/$projectId';

  // Project Details
  static String projectDetails(String projectId) => '/projects/$projectId';
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
      final isOnAuthPage =
          currentPath == AppRoutes.login ||
          currentPath == AppRoutes.resetPassword;

      // If logged in and on auth page, redirect to dashboard
      if (isLoggedIn && isOnAuthPage) {
        return AppRoutes.dashboard;
      }

      // If not logged in and not on auth page, redirect to login
      if (!isLoggedIn && !isOnAuthPage) {
        return AppRoutes.login;
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
            pageBuilder: (context, state) {
              return FadePageTransition(
                key: state.pageKey,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthAuthenticated &&
                        authState.user.isSiteEngineer) {
                      return BlocProvider(
                        create: (context) =>
                            ProjectsBloc(repository: ProjectsRepositoryImpl())
                              ..add(
                                const LoadProjects(
                                  status: ProjectStatus.execution,
                                ),
                              ),
                        child: const ProjectsListPage(
                          title: 'مشاريع التنفيذ',
                          emptyMessage: 'لا توجد مشاريع تنفيذ',
                          showCreateButton: false,
                          showArchiveActions: false,
                          showStatusActions: false,
                          visibleStatuses: {ProjectStatus.execution},
                        ),
                      );
                    }
                    return const DashboardPage();
                  },
                ),
              );
            },
          ),

          // Project Details (must come before /projects to avoid route conflict)
          GoRoute(
            path: AppRoutes.archivedProjects,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) =>
                    ProjectsBloc(repository: ProjectsRepositoryImpl())
                      ..add(const LoadProjects(archived: true)),
                child: const ProjectsListPage(
                  title: 'الأرشيف',
                  emptyMessage: 'لا توجد مشاريع مؤرشفة',
                  showCreateButton: false,
                  showArchiveActions: false,
                  showRestoreActions: true,
                  showStatusActions: false,
                  enableNavigation: true,
                ),
              ),
            ),
          ),

          GoRoute(
            path: AppRoutes.completedProjects,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => ProjectsBloc(
                  repository: ProjectsRepositoryImpl(),
                )..add(const LoadProjects(status: ProjectStatus.completed)),
                child: ProjectsListPage(
                  key: ValueKey(
                    'completed-projects-${state.uri.queryParameters['refresh'] ?? 'initial'}',
                  ),
                  title: 'المشاريع المكتملة',
                  emptyMessage: 'لا توجد مشاريع مكتملة',
                  showCreateButton: false,
                ),
              ),
            ),
          ),

          GoRoute(
            path: AppRoutes.siteEngineerPricingProjects,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) =>
                    ProjectsBloc(repository: ProjectsRepositoryImpl())
                      ..add(const LoadProjects()),
                child: const ProjectsListPage(
                  title: 'قيد التسعير أو بانتظار التوقيع',
                  emptyMessage: 'لا توجد مشاريع قيد التسعير أو بانتظار التوقيع',
                  showCreateButton: false,
                  showArchiveActions: false,
                  showStatusActions: false,
                  visibleStatuses: {
                    ProjectStatus.underPricing,
                    ProjectStatus.pendingSignature,
                  },
                ),
              ),
            ),
          ),

          // Project Details (must come before /projects to avoid route conflict)
          GoRoute(
            path: '/projects/:projectId',
            pageBuilder: (context, state) {
              final projectId = state.pathParameters['projectId'] ?? '';
              return FadePageTransition(
                key: state.pageKey,
                child: BlocProvider(
                  create: (context) =>
                      ProjectsBloc(repository: ProjectsRepositoryImpl())
                        ..add(const LoadProjects()),
                  child: ProjectDetailsPage(projectId: projectId),
                ),
              );
            },
          ),

          // Projects List
          GoRoute(
            path: AppRoutes.projects,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) =>
                    ProjectsBloc(repository: ProjectsRepositoryImpl())
                      ..add(const LoadProjects()),
                child: ProjectsListPage(
                  key: ValueKey(
                    'projects-${state.uri.queryParameters['refresh'] ?? 'initial'}',
                  ),
                ),
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

          // Notifications
          GoRoute(
            path: AppRoutes.notifications,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: const NotificationsPage(),
            ),
          ),

          // Reminders
          GoRoute(
            path: AppRoutes.reminders,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: const _PlaceholderPage(
                title: 'التذكيرات',
                icon: Icons.notifications_active_outlined,
                subtitle: 'قريباً - إدارة التذكيرات والمواعيد',
              ),
            ),
          ),

          // Pricing
          GoRoute(
            path: '/pricing/:projectId',
            pageBuilder: (context, state) {
              final projectId = state.pathParameters['projectId'] ?? '';
              return FadePageTransition(
                key: state.pageKey,
                child: UnderPricingPage(
                  projectId: projectId,
                  readOnly: state.uri.queryParameters['readOnly'] == 'true',
                  hideFinancials:
                      state.uri.queryParameters['hideFinancials'] == 'true',
                ),
              );
            },
          ),

          // Execution
          GoRoute(
            path: '/execution/:projectId',
            pageBuilder: (context, state) {
              final projectId = state.pathParameters['projectId'] ?? '';
              return FadePageTransition(
                key: state.pageKey,
                child: ExecutionPage(projectId: projectId),
              );
            },
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) =>
        FadePageTransition(key: state.pageKey, child: const ErrorPage()),
  );
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
            child: Icon(icon, size: 64, color: const Color(0xFF8B949E)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF8B949E)),
          ),
        ],
      ),
    );
  }
}
