import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/enums/task_status.dart';
import '../../../tasks/domain/enums/task_type.dart';
import '../../../tasks/data/datasources/mock_tasks_datasource.dart';
import '../../../projects/domain/entities/team_member_entity.dart';
import '../widgets/gantt_filters_widget.dart';
import '../widgets/gantt_warnings_widget.dart';
import '../widgets/status_legend_widget.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/appointment_widgets.dart';

/// Gantt Chart page for task visualization
class GanttChartPage extends StatefulWidget {
  const GanttChartPage({super.key});

  @override
  State<GanttChartPage> createState() => _GanttChartPageState();
}

class _GanttChartPageState extends State<GanttChartPage> {
  final MockTasksDataSource _dataSource = MockTasksDataSource();

  GanttTimePeriod _selectedPeriod = GanttTimePeriod.week;
  bool _showTeamTasks = true;
  String? _selectedMemberId;
  bool _showWarnings = true;

  late List<TaskEntity> _tasks;
  late List<TeamMemberEntity> _teamMembers;
  late List<TeamMemberEntity> _overloadedMembers;
  late List<String> _delayedProjects;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _teamMembers = _dataSource.getTeamMembers();
    _overloadedMembers = _dataSource.getMembersWithOverload();
    _delayedProjects = _dataSource.getDelayedProjects();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      if (_showTeamTasks) {
        _tasks = _dataSource.getTasks(assigneeId: _selectedMemberId);
      } else {
        // In real app, this would filter by current user
        _tasks = _dataSource.getTasks(assigneeId: 'tm-1');
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedPeriod = GanttTimePeriod.week;
      _showTeamTasks = true;
      _selectedMemberId = null;
    });
    _applyFilters();
  }

  /// Get start date (Saturday of current week)
  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case GanttTimePeriod.today:
        return DateTime(now.year, now.month, now.day);
      case GanttTimePeriod.week:
        // Week starts on Saturday
        int daysToSubtract = (now.weekday + 1) % 7;
        return DateTime(now.year, now.month, now.day - daysToSubtract);
      case GanttTimePeriod.month:
        return DateTime(now.year, now.month, 1);
      case GanttTimePeriod.threeMonths:
        return DateTime(now.year, now.month - 2, 1);
    }
  }

  int _getViewDays() {
    switch (_selectedPeriod) {
      case GanttTimePeriod.today:
        return 1;
      case GanttTimePeriod.week:
        return 7; // Saturday to Friday
      case GanttTimePeriod.month:
        return 30;
      case GanttTimePeriod.threeMonths:
        return 90;
    }
  }

  void _showAddTaskDialog({String? memberId, DateTime? date}) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        teamMembers: _teamMembers,
        preselectedMemberId: memberId,
        preselectedDate: date,
        onTaskAdded: (task) {
          setState(() {
            _dataSource.addTask(task);
            _applyFilters();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إضافة المهمة: ${task.name}'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
        },
      ),
    );
  }

  void _showAppointmentDetails(TaskEntity task) {
    showDialog(
      context: context,
      builder: (context) => AppointmentDetailsDialog(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startDate = _getStartDate();

    return Scaffold(
      backgroundColor: AppColors.sidebarBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.scaffoldBackground,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مهمة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'مخطط جانت - توزيع المهام',
              style: AppTextStyles.pageTitle,
            ),
            const SizedBox(height: 24),

            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: GanttFiltersWidget(
                selectedPeriod: _selectedPeriod,
                showTeamTasks: _showTeamTasks,
                selectedMemberId: _selectedMemberId,
                teamMembers: _teamMembers,
                onPeriodChanged: (period) {
                  setState(() => _selectedPeriod = period);
                },
                onTeamTasksChanged: (showTeam) {
                  setState(() => _showTeamTasks = showTeam);
                },
                onMemberChanged: (memberId) {
                  setState(() => _selectedMemberId = memberId);
                },
                onApplyFilters: _applyFilters,
                onClearFilters: _clearFilters,
              ),
            ),
            const SizedBox(height: 16),

            // Warnings
            if (_showWarnings)
              GanttWarningsWidget(
                overloadedMembers: _overloadedMembers,
                delayedProjects: _delayedProjects,
                onDismiss: () {
                  setState(() => _showWarnings = false);
                },
              ),

            // Status Legend
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: StatusLegendWidget(),
            ),

            // Gantt Chart
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: _teamMembers.isEmpty
                    ? _buildEmptyState()
                    : _buildGanttChart(startDate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مهام',
            style: AppTextStyles.h5.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على مهام في الفترة المحددة',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildGanttChart(DateTime startDate) {
    final days = _getViewDays();
    final displayDays = days > 7 ? 7 : days;

    // Group tasks by employee
    final tasksByEmployee = <String, List<TaskEntity>>{};
    for (final member in _teamMembers) {
      tasksByEmployee[member.id] =
          _tasks.where((task) => task.assigneeId == member.id).toList();
    }

    return Column(
      children: [
        // Header with dates
        _buildDateHeader(startDate, displayDays),

        // Employee rows
        Expanded(
          child: ListView.builder(
            itemCount: _teamMembers.length,
            itemBuilder: (context, index) {
              final member = _teamMembers[index];
              final memberTasks = tasksByEmployee[member.id] ?? [];

              return _buildEmployeeRow(
                  member, memberTasks, startDate, displayDays);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(DateTime startDate, int displayDays) {
    final dayFormat = DateFormat('EEEE', 'ar');
    final dateFormat = DateFormat('d', 'ar');

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.tableHeader,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Employee name column header
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Text(
              'الموظفين',
              style: AppTextStyles.tableHeader,
            ),
          ),
          // Date columns with vertical lines
          Expanded(
            child: Row(
              children: List.generate(displayDays, (i) {
                final date = startDate.add(Duration(days: i));
                final isToday = _isToday(date);
                final isWeekend = date.weekday == DateTime.friday;

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : (isWeekend
                              ? AppColors.surfaceColor.withValues(alpha: 0.3)
                              : null),
                      border: const Border(
                        left: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayFormat.format(date),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primary : null,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              dateFormat.format(date),
                              style: TextStyle(
                                color: isToday
                                    ? AppColors.scaffoldBackground
                                    : AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildEmployeeRow(
    TeamMemberEntity member,
    List<TaskEntity> tasks,
    DateTime startDate,
    int displayDays,
  ) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          // Employee info column
          Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    member.name.substring(0, 1),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Name and role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        member.name,
                        style: AppTextStyles.tableCellBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.role,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Gantt bar area with vertical lines
          Expanded(
            child: _buildGanttBarsForEmployee(
                member, tasks, startDate, displayDays),
          ),
        ],
      ),
    );
  }

  Widget _buildGanttBarsForEmployee(
    TeamMemberEntity member,
    List<TaskEntity> tasks,
    DateTime startDate,
    int displayDays,
  ) {
    final endDate = startDate.add(Duration(days: displayDays));

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayWidth = constraints.maxWidth / displayDays;

        return Stack(
          children: [
            // Clickable day cells
            Row(
              children: List.generate(displayDays, (i) {
                final date = startDate.add(Duration(days: i));
                final isToday = _isToday(date);
                final isWeekend = date.weekday == DateTime.friday;

                return Expanded(
                  child: InkWell(
                    onTap: () => _showAddTaskDialog(
                      memberId: member.id,
                      date: date,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : (isWeekend
                                ? AppColors.surfaceColor.withValues(alpha: 0.2)
                                : null),
                        border: const Border(
                          left: BorderSide(color: AppColors.border, width: 1),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            // Task bars and appointment circles
            ...tasks.map((task) {
              // Check if task is visible in this range
              if (task.endDate.isBefore(startDate) ||
                  task.startDate.isAfter(endDate)) {
                return const SizedBox.shrink();
              }

              final taskStart = task.startDate.isBefore(startDate)
                  ? startDate
                  : task.startDate;
              final taskEnd =
                  task.endDate.isAfter(endDate) ? endDate : task.endDate;

              final startOffset =
                  taskStart.difference(startDate).inDays.toDouble();

              if (task.isAppointment) {
                // Render as circle for appointments
                final circleLeft = startOffset * dayWidth + (dayWidth / 2) - 16;

                return Positioned(
                  left: circleLeft,
                  top: 20,
                  child: AppointmentCircle(
                    task: task,
                    onTap: () => _showAppointmentDetails(task),
                  ),
                );
              } else {
                // Render as bar for work tasks and general tasks
                final duration =
                    taskEnd.difference(taskStart).inDays.toDouble() + 1;
                final barLeft = startOffset * dayWidth;
                final barWidth = duration * dayWidth;

                return Positioned(
                  left: barLeft + 4,
                  top: 20,
                  child: _buildTaskBar(task, barWidth, constraints.maxWidth - barLeft - 8),
                );
              }
            }),
          ],
        );
      },
    );
  }

  Widget _buildTaskBar(TaskEntity task, double barWidth, double maxWidth) {
    final color = task.taskType == TaskType.generalTask
        ? TaskType.generalTask.color
        : task.status.color;

    return Container(
      width: (barWidth - 8).clamp(40, maxWidth),
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Task type indicator
          Icon(
            task.taskType.icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              task.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
