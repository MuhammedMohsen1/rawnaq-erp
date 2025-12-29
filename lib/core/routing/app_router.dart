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
import '../../features/gantt/presentation/pages/gantt_chart_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/projects/presentation/pages/site_engineer_dashboard_page.dart';
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

      // If not logged in and not on auth page, redirect to login
      if (!isLoggedIn && !isOnAuthPage) {
        return AppRoutes.login;
      }

      // Allow login page to be shown even if logged in (user can logout)
      // Only redirect from auth pages if explicitly navigating to dashboard
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
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthAuthenticated &&
                      authState.user.isSiteEngineer) {
                    return const SiteEngineerDashboardPage();
                  }
                  return const _DashboardPage();
                },
              ),
            ),
          ),

          // Projects
          GoRoute(
            path: AppRoutes.projects,
            pageBuilder: (context, state) => FadePageTransition(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) =>
                    ProjectsBloc(repository: ProjectsRepositoryImpl())
                      ..add(const LoadProjects()),
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
        ],
      ),
    ],
    errorPageBuilder: (context, state) =>
        FadePageTransition(key: state.pageKey, child: const ErrorPage()),
  );
}

// Dashboard page with statistics overview
class _DashboardPage extends StatefulWidget {
  const _DashboardPage();

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  String _selectedPeriod = 'Year';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProjectsBloc(repository: ProjectsRepositoryImpl())
            ..add(const LoadProjects()),
      child: BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Key Metrics Section
                _buildStatsCards(context),
                const SizedBox(height: 32),

                // Financial Overview Section
                _buildFinancialOverview(context),
                const SizedBox(height: 32),

                // Recent Users and Activity Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildRecentUsers(context)),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildRecentActivity(context)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'المشاريع النشطة',
            value: '12',
            icon: Icons.people,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'المشاريع المتأخرة',
            value: '3',
            icon: Icons.people,
            color: const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'المشاريع المعلقة',
            value: '2',
            icon: Icons.folder,
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'المدفوعات المعلقة',
            value: '\$1,999',
            icon: Icons.attach_money,
            color: const Color(0xFF22C55E),
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
              const Spacer(),
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8B949E)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نظرة عامة مالية',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'التسعير الفعلي مقابل التكلفة الفعلية',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$450,000',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF22C55E,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+12.5%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(0xFF22C55E),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Time period selector
          Row(
            children: [
              _buildPeriodButton('سنة', _selectedPeriod == 'Year'),
              const SizedBox(width: 8),
              _buildPeriodButton('شهر', _selectedPeriod == 'Month'),
              const SizedBox(width: 8),
              _buildPeriodButton('أسبوع', _selectedPeriod == 'Week'),
            ],
          ),
          const SizedBox(height: 24),
          // Chart placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'تصور الرسم البياني',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF8B949E),
                ),
              ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          // Map Arabic text back to English for internal state
          if (period == 'سنة') {
            _selectedPeriod = 'Year';
          } else if (period == 'شهر') {
            _selectedPeriod = 'Month';
          } else if (period == 'أسبوع') {
            _selectedPeriod = 'Week';
          } else {
            _selectedPeriod = period;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFF30363D),
          ),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFF8B949E),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentUsers(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text(
                'المستخدمون الأخيرون',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('عرض الكل')),
            ],
          ),
          const SizedBox(height: 16),
          // Table
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1),
            },
            children: [
              // Header
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF30363D), width: 1),
                  ),
                ),
                children: [
                  _buildTableCell('اسم المستخدم', isHeader: true),
                  _buildTableCell('البريد الإلكتروني', isHeader: true),
                  _buildTableCell('الدور', isHeader: true),
                  _buildTableCell('الحالة', isHeader: true),
                  _buildTableCell('الإجراءات', isHeader: true),
                ],
              ),
              // Rows
              _buildUserRow(
                'رفيدة أحمد',
                'Rofida@Rawnaq.com',
                'مدير',
                'نشط',
                const Color(0xFF22C55E),
              ),
              _buildUserRow(
                'شيماء علي',
                'Shymaa@Rawnaq.com',
                'مدير مشروع',
                'غياب',
                const Color(0xFFF59E0B),
              ),
              _buildUserRow(
                'أبو مكة',
                'AboMaka@Rawnaq.com',
                'مهندس',
                'غير نشط',
                const Color(0xFF6E7681),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildUserRow(
    String name,
    String email,
    String role,
    String status,
    Color statusColor,
  ) {
    return TableRow(
      children: [
        _buildTableCell(name),
        _buildTableCell(email),
        _buildTableCell(role),
        _buildTableCellWithStatus(status, statusColor),
        _buildTableCell('', isAction: true),
      ],
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isAction = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: isAction
          ? const Icon(Icons.more_vert, color: Color(0xFF8B949E), size: 20)
          : Text(
              text,
              style: TextStyle(
                color: isHeader ? const Color(0xFF8B949E) : Colors.white,
                fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
    );
  }

  Widget _buildTableCellWithStatus(String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النشاط الأخير',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('عرض الكل')),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActivityItem(
                Icons.description,
                'تم رفع مخطط جديد',
                'رفع أحمد "الموقع أ - المرحلة 2.pdf"',
                'منذ 25 دقيقة',
              ),
              const SizedBox(height: 16),
              _buildActivityItem(
                Icons.check_circle,
                'تمت الموافقة على الفاتورة',
                'وافق المدير المالي على الفاتورة رقم 3092',
                'منذ ساعتين',
                iconColor: const Color(0xFF22C55E),
              ),
              const SizedBox(height: 16),
              _buildActivityItem(
                Icons.warning,
                'تنبيه نقص المواد',
                'مخزون منخفض من أكياس الأسمنت (النوع 2)',
                'منذ 5 ساعات',
                iconColor: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 16),
              _buildActivityItem(
                Icons.warning,
                'تنبيه نقص المواد',
                'مخزون منخفض من أكياس الأسمنت (النوع 2)',
                'منذ 5 ساعات',
                iconColor: const Color(0xFFF59E0B),
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String description,
    String time, {
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF3B82F6)).withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? const Color(0xFF3B82F6),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(color: Color(0xFF6E7681), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
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
