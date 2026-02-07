import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../projects/data/repositories/projects_repository_impl.dart';
import '../../../projects/domain/enums/project_status.dart';
import '../../../projects/presentation/bloc/projects_bloc.dart';
import '../../../projects/presentation/bloc/projects_event.dart';
import '../../../projects/presentation/bloc/projects_state.dart';

// Dashboard page with statistics overview
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedPeriod = 'Year';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProjectsBloc(repository: ProjectsRepositoryImpl())
            ..add(const LoadProjects()),
      child: BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final isCompact = constraints.maxWidth < 900;
              final padding = isNarrow ? 16.0 : isCompact ? 20.0 : 24.0;

              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
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
                    if (isNarrow)
                      Column(
                        children: [
                          _buildRecentUsers(context),
                          const SizedBox(height: 24),
                          _buildRecentActivity(context),
                        ],
                      )
                    else
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
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        // Get statistics from state
        int activeCount = 0;
        int delayedCount = 0;
        int onHoldCount = 0;

        if (state is ProjectsLoaded && state.statistics != null) {
          activeCount = state.statistics!.active;
          delayedCount = state.statistics!.delayed;
          onHoldCount = state.statistics!.onHold;
        } else if (state is ProjectsLoaded) {
          // Calculate from projects if statistics not available
          // Map new statuses to old statistics categories:
          // active = execution (projects in execution phase)
          // delayed = 0 (no longer tracked separately)
          // onHold = draft + underPricing + profitPending + pendingApproval
          final execution = state.projects
              .where((p) => p.status == ProjectStatus.execution)
              .length;
          final draft =
              state.projects.where((p) => p.status == ProjectStatus.draft).length;
          final underPricing = state.projects
              .where((p) => p.status == ProjectStatus.underPricing)
              .length;
          final profitPending = state.projects
              .where((p) => p.status == ProjectStatus.pendingSignature)
              .length;
          final pendingApproval = state.projects
              .where((p) => p.status == ProjectStatus.pendingApproval)
              .length;

          activeCount = execution;
          delayedCount = 0; // No longer tracked separately
          onHoldCount = draft + underPricing + profitPending + pendingApproval;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 520;
            final isCompact = constraints.maxWidth < 900;

            final cards = [
              _buildStatCard(
                context,
                title: 'المشاريع النشطة',
                value: activeCount.toString(),
                icon: Icons.folder,
                color: const Color(0xFF3B82F6),
              ),
              _buildStatCard(
                context,
                title: 'المشاريع المتأخرة',
                value: delayedCount.toString(),
                icon: Icons.warning,
                color: const Color(0xFFEF4444),
              ),
              _buildStatCard(
                context,
                title: 'المشاريع المعلقة',
                value: onHoldCount.toString(),
                icon: Icons.pause_circle,
                color: const Color(0xFFF59E0B),
              ),
              _buildStatCard(
                context,
                title: 'المشاريع المكتملة',
                value: state is ProjectsLoaded && state.statistics != null
                    ? state.statistics!.completed.toString()
                    : state is ProjectsLoaded
                        ? state.projects
                            .where((p) => p.status == ProjectStatus.completed)
                            .length
                            .toString()
                        : '0',
                icon: Icons.check_circle,
                color: const Color(0xFF22C55E),
              ),
            ];

            if (isNarrow) {
              return Column(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    cards[i],
                    if (i != cards.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }

            if (isCompact) {
              final cardWidth = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final card in cards)
                    SizedBox(width: cardWidth, child: card),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 16),
                Expanded(child: cards[1]),
                const SizedBox(width: 16),
                Expanded(child: cards[2]),
                const SizedBox(width: 16),
                Expanded(child: cards[3]),
              ],
            );
          },
        );
      },
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
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: const Color(0xFF8B949E)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final padding = isNarrow ? 16.0 : 24.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNarrow)
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
                    const SizedBox(height: 12),
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
                            color: const Color(0xFF22C55E)
                                .withValues(alpha: 0.15),
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
                )
              else
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
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: 0.15),
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
              if (isNarrow)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPeriodButton('سنة', _selectedPeriod == 'Year'),
                    _buildPeriodButton('شهر', _selectedPeriod == 'Month'),
                    _buildPeriodButton('أسبوع', _selectedPeriod == 'Week'),
                  ],
                )
              else
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
                height: isNarrow ? 160 : 200,
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
      },
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
    const users = [
      _UserRowData(
        name: 'رفيدة أحمد',
        email: 'Rofida@Rawnaq.com',
        role: 'مدير',
        status: 'نشط',
        statusColor: Color(0xFF22C55E),
      ),
      _UserRowData(
        name: 'شيماء علي',
        email: 'Shymaa@Rawnaq.com',
        role: 'مدير مشروع',
        status: 'غياب',
        statusColor: Color(0xFFF59E0B),
      ),
      _UserRowData(
        name: 'أبو مكة',
        email: 'AboMaka@Rawnaq.com',
        role: 'مهندس',
        status: 'غير نشط',
        statusColor: Color(0xFF6E7681),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final padding = isNarrow ? 16.0 : 24.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isNarrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المستخدمون الأخيرون',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('عرض الكل'),
                      ),
                    ),
                  ],
                )
              else
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
              if (isNarrow)
                Column(
                  children: [
                    for (int i = 0; i < users.length; i++) ...[
                      _buildUserCard(users[i]),
                      if (i != users.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: Table(
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
                              bottom: BorderSide(
                                color: Color(0xFF30363D),
                                width: 1,
                              ),
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
                        for (final user in users)
                          _buildUserRow(
                            user.name,
                            user.email,
                            user.role,
                            user.status,
                            user.statusColor,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final padding = isNarrow ? 16.0 : 24.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNarrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النشاط الأخير',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('عرض الكل'),
                      ),
                    ),
                  ],
                )
              else
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
      },
    );
  }

  Widget _buildUserCard(_UserRowData user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.more_vert,
                color: Color(0xFF8B949E),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            user.role,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: user.statusColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                user.status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
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

class _UserRowData {
  final String name;
  final String email;
  final String role;
  final String status;
  final Color statusColor;

  const _UserRowData({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.statusColor,
  });
}
