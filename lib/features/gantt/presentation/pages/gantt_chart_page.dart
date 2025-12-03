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
import '../widgets/add_task_dialog_simple.dart';
import '../widgets/appointment_widgets.dart';
import '../widgets/edit_task_dialog.dart';

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
  bool _isDraftPanelExpanded = true;

  late List<TaskEntity> _tasks;
  late List<TaskEntity> _draftTasks;
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
    _draftTasks = _dataSource.getDraftTasks();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      if (_showTeamTasks) {
        _tasks = _dataSource.getTasks(assigneeId: _selectedMemberId)
            .where((t) => !t.isDraft && t.assigneeId != null)
            .toList();
      } else {
        _tasks = _dataSource.getTasks(assigneeId: 'tm-1')
            .where((t) => !t.isDraft && t.assigneeId != null)
            .toList();
      }
      _draftTasks = _dataSource.getDraftTasks();
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

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case GanttTimePeriod.today:
        return DateTime(now.year, now.month, now.day);
      case GanttTimePeriod.week:
        int daysToSubtract = (now.weekday + 1) % 7;
        return DateTime(now.year, now.month, now.day - daysToSubtract);
      case GanttTimePeriod.month:
        return DateTime(now.year, now.month, 1);
      case GanttTimePeriod.threeMonths:
        return DateTime(now.year, now.month - 2, 1);
    }
  }

  int _getViewDays() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case GanttTimePeriod.today:
        return 1;
      case GanttTimePeriod.week:
        return 7;
      case GanttTimePeriod.month:
        // Calculate actual days in current month
        return _daysInMonth(now.year, now.month);
      case GanttTimePeriod.threeMonths:
        // Calculate actual days in 3-month period
        final startMonth = now.month - 2;
        final startYear = startMonth <= 0 ? now.year - 1 : now.year;
        final adjustedStartMonth = startMonth <= 0 ? startMonth + 12 : startMonth;
        int totalDays = 0;
        for (int i = 0; i < 3; i++) {
          int m = adjustedStartMonth + i;
          int y = startYear;
          if (m > 12) {
            m -= 12;
            y++;
          }
          totalDays += _daysInMonth(y, m);
        }
        return totalDays;
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialogSimple(
        onTaskAdded: (task) {
          setState(() {
            _dataSource.addTask(task);
            _applyFilters();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إضافة المهمة: ${task.name}'),
              backgroundColor: AppColors.statusOnHold,
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

  void _onTaskDropped(TaskEntity task, String assigneeId, DateTime date) {
    setState(() {
      if (task.isDraft || task.assigneeId == null) {
        // Assign draft task to employee starting from dropped date
        _dataSource.assignTask(task.id, assigneeId, date);
      } else {
        // Update existing task - new start date (keeps duration), optionally new assignee
        _dataSource.updateTaskDates(task.id, date, newAssigneeId: assigneeId);
      }
      _applyFilters();
    });

    final action = (task.isDraft || task.assigneeId == null) 
        ? 'تم تعيين المهمة' 
        : (task.assigneeId != assigneeId ? 'تم نقل المهمة' : 'تم تحديث تاريخ المهمة');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action: ${task.name}'),
        backgroundColor: AppColors.statusCompleted,
      ),
    );
  }

  /// Called when a task is resized by dragging its edges
  void _onTaskResized(TaskEntity task, DateTime newStart, DateTime newEnd) {
    setState(() {
      final updatedTask = task.copyWith(
        startDate: newStart,
        endDate: newEnd,
      );
      _dataSource.updateTask(updatedTask);
      _applyFilters();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تعديل مدة المهمة: ${task.name}'),
        backgroundColor: AppColors.statusCompleted,
      ),
    );
  }

  void _showEditTaskDialog(TaskEntity task) {
    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(
        task: task,
        teamMembers: _teamMembers,
        onTaskUpdated: (updatedTask) {
          setState(() {
            _dataSource.updateTask(updatedTask);
            _applyFilters();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث المهمة: ${updatedTask.name}'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
        },
        onTaskDeleted: () {
          setState(() {
            _dataSource.deleteTask(task.id);
            _applyFilters();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف المهمة: ${task.name}'),
              backgroundColor: AppColors.statusDelayed,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startDate = _getStartDate();

    return Scaffold(
      backgroundColor: AppColors.sidebarBackground,
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

            // Filters row (compact)
            GanttFiltersWidget(
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
            const SizedBox(height: 12),

            // Draft tasks + Warnings + Legend (compact row)
            _buildCompactInfoBar(),
            const SizedBox(height: 12),

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

  /// Compact info bar: Draft tasks (expandable) + Warnings + Status Legend
  Widget _buildCompactInfoBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Main row: Draft tasks toggle + Warnings + Legend
          InkWell(
            onTap: () => setState(() => _isDraftPanelExpanded = !_isDraftPanelExpanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Draft tasks badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _draftTasks.isEmpty
                          ? AppColors.surfaceColor
                          : AppColors.statusOnHold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pending_actions,
                          size: 16,
                          color: _draftTasks.isEmpty
                              ? AppColors.textMuted
                              : AppColors.statusOnHold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'معلقة: ${_draftTasks.length}',
                          style: TextStyle(
                            color: _draftTasks.isEmpty
                                ? AppColors.textMuted
                                : AppColors.statusOnHold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isDraftPanelExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Warnings (compact)
                  if (_overloadedMembers.isNotEmpty)
                    _buildCompactWarning(
                      icon: Icons.warning_amber,
                      text: 'مثقل: ${_overloadedMembers.length}',
                      color: AppColors.statusDelayed,
                    ),
                  if (_delayedProjects.isNotEmpty)
                    _buildCompactWarning(
                      icon: Icons.schedule,
                      text: 'متأخر: ${_delayedProjects.length}',
                      color: AppColors.statusOnHold,
                    ),

                  const Spacer(),

                  // Add task button
                  TextButton.icon(
                    onPressed: _showAddTaskDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('إضافة مهمة'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(width: 8),
                  Container(width: 1, height: 24, color: AppColors.divider),
                  const SizedBox(width: 8),

                  // Status legend (inline)
                  ..._buildInlineLegend(),
                ],
              ),
            ),
          ),

          // Expandable draft tasks
          if (_isDraftPanelExpanded && _draftTasks.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.touch_app, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'اسحب المهمة إلى الموظف لتعيينها',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _draftTasks.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _buildDraggableDraftChip(task),
                        );
                      }).toList(),
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

  Widget _buildCompactWarning({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInlineLegend() {
    final items = [
      (TaskStatus.inProgress, 'جاري'),
      (TaskStatus.completed, 'مكتمل'),
      (TaskStatus.waiting, 'انتظار'),
      (TaskStatus.delayed, 'متأخر'),
    ];

    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: item.$1.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item.$2,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDraggableDraftChip(TaskEntity task) {
    return Draggable<TaskEntity>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: _buildDraftChipContent(task, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildDraftChipContent(task),
      ),
      child: _buildDraftChipContent(task),
    );
  }

  Widget _buildDraftChipContent(TaskEntity task, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDragging ? AppColors.cardBackground : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDragging ? AppColors.primary : AppColors.border,
          width: isDragging ? 2 : 1,
        ),
        boxShadow: isDragging
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12)]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            task.taskType.icon,
            size: 14,
            color: task.taskType.color,
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              task.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDragging ? AppColors.primary : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (task.projectName != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                task.projectName!,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
          const SizedBox(width: 6),
          Icon(
            Icons.drag_indicator,
            size: 14,
            color: isDragging ? AppColors.primary : AppColors.textMuted,
          ),
        ],
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
    final displayDays = _getViewDays();

    final tasksByEmployee = <String, List<TaskEntity>>{};
    for (final member in _teamMembers) {
      tasksByEmployee[member.id] =
          _tasks.where((task) => task.assigneeId == member.id).toList();
    }

    // For month/3-month views, wrap in horizontal scroll
    final needsHorizontalScroll = displayDays > 14;

    Widget chartContent = Column(
      children: [
        _buildDateHeader(startDate, displayDays),
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

    if (needsHorizontalScroll) {
      // Calculate minimum width for comfortable viewing (60px per day)
      final minWidth = 200.0 + (displayDays * 60.0);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: minWidth,
          child: chartContent,
        ),
      );
    }

    return chartContent;
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
          Expanded(
            child: Row(
              children: List.generate(displayDays, (i) {
                // Create a normalized date for this column
                final date = DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day + i,
                );
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

  /// Calculate the number of days between two dates using raw year/month/day values
  /// This avoids any timezone/DateTime object issues
  int _daysBetweenDates(int fromYear, int fromMonth, int fromDay, 
                        int toYear, int toMonth, int toDay) {
    final fromJulian = _toJulianDay(fromYear, fromMonth, fromDay);
    final toJulian = _toJulianDay(toYear, toMonth, toDay);
    return toJulian - fromJulian;
  }

  /// Convert a date to Julian day number (accurate calendar calculation)
  int _toJulianDay(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  }
  
  /// Get the actual number of days in a month
  int _daysInMonth(int year, int month) {
    // Use DateTime to get the last day of the month
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    return lastDayOfMonth.day;
  }
  
  /// Convert time to fraction of day (0.0 to 1.0)
  /// 00:00 = 0.0, 12:00 = 0.5, 23:59 = ~1.0
  double _timeToFraction(DateTime dateTime) {
    return (dateTime.hour * 60 + dateTime.minute) / (24 * 60);
  }
  
  /// Convert a pixel offset within a day to DateTime
  /// Used for resizing task bars
  DateTime _fractionToDateTime(DateTime baseDate, double fraction) {
    final totalMinutes = (fraction * 24 * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hours.clamp(0, 23),
      minutes.clamp(0, 59),
    );
  }
  
  /// Calculate precise position including time offset (for RTL layout)
  /// Returns the position from the RIGHT edge of the chart
  double _calculateTaskPosition(
    int taskYear, int taskMonth, int taskDay,
    int chartStartYear, int chartStartMonth, int chartStartDay,
    double timeFraction,
    double dayWidth,
  ) {
    final dayOffset = _toJulianDay(taskYear, taskMonth, taskDay) - 
                      _toJulianDay(chartStartYear, chartStartMonth, chartStartDay);
    return (dayOffset + timeFraction) * dayWidth;
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
    // Calculate end date using DateTime constructor (handles month overflow correctly)
    final endDate = DateTime(startDate.year, startDate.month, startDate.day + displayDays);
    
    // Store chart bounds as raw values for Julian day calculation
    final chartStartYear = startDate.year;
    final chartStartMonth = startDate.month;
    final chartStartDay = startDate.day;
    final chartEndYear = endDate.year;
    final chartEndMonth = endDate.month;
    final chartEndDay = endDate.day;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayWidth = constraints.maxWidth / displayDays;

        return Stack(
          children: [
            // Drop targets for each day
            Row(
              children: List.generate(displayDays, (i) {
                // Create a normalized date for this column (midnight local)
                final columnDate = DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day + i,
                );
                final isToday = _isToday(columnDate);
                final isWeekend = columnDate.weekday == DateTime.friday;

                return Expanded(
                  child: DragTarget<TaskEntity>(
                    onWillAcceptWithDetails: (details) => true,
                    onAcceptWithDetails: (details) {
                      _onTaskDropped(details.data, member.id, columnDate);
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovering = candidateData.isNotEmpty;
                      return Container(
                        decoration: BoxDecoration(
                          color: isHovering
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : (isToday
                                  ? AppColors.primary.withValues(alpha: 0.05)
                                  : (isWeekend
                                      ? AppColors.surfaceColor
                                          .withValues(alpha: 0.2)
                                      : null)),
                          border: Border(
                            left: const BorderSide(
                                color: AppColors.border, width: 1),
                          ),
                        ),
                        child: isHovering
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                );
              }),
            ),
            // Task bars and appointment circles
            // Note: RTL layout - position from RIGHT to match header display
            ...tasks.map((task) {
              // Extract raw year/month/day values directly from task dates
              final taskStartYear = task.startDate.year;
              final taskStartMonth = task.startDate.month;
              final taskStartDay = task.startDate.day;
              final taskEndYear = task.endDate.year;
              final taskEndMonth = task.endDate.month;
              final taskEndDay = task.endDate.day;

              // Calculate Julian days for comparison
              final taskStartJulian = _toJulianDay(taskStartYear, taskStartMonth, taskStartDay);
              final taskEndJulian = _toJulianDay(taskEndYear, taskEndMonth, taskEndDay);
              final chartStartJulian = _toJulianDay(chartStartYear, chartStartMonth, chartStartDay);
              final chartEndJulian = _toJulianDay(chartEndYear, chartEndMonth, chartEndDay);

              // Skip tasks outside the visible range
              if (taskEndJulian < chartStartJulian || taskStartJulian > chartEndJulian) {
                return const SizedBox.shrink();
              }

              // Calculate time fractions for sub-day positioning
              final startTimeFraction = _timeToFraction(task.startDate);
              final endTimeFraction = _timeToFraction(task.endDate);

              // Clamp task dates to visible range (using Julian days)
              final visibleStartJulian = taskStartJulian < chartStartJulian 
                  ? chartStartJulian 
                  : taskStartJulian;
              final visibleEndJulian = taskEndJulian > chartEndJulian 
                  ? chartEndJulian 
                  : taskEndJulian;

              // Calculate precise offset including time (in day fractions)
              // If task starts before chart, use chart start (0.0 time fraction)
              final visibleStartTimeFraction = taskStartJulian < chartStartJulian 
                  ? 0.0 
                  : startTimeFraction;
              // If task ends after chart, use chart end (1.0 time fraction)
              final visibleEndTimeFraction = taskEndJulian > chartEndJulian 
                  ? 1.0 
                  : endTimeFraction;

              // Calculate offset from chart start (in days + time fraction)
              final startOffset = (visibleStartJulian - chartStartJulian) + visibleStartTimeFraction;
              
              // Calculate duration including time fractions
              // Duration = (end day - start day) + (end time fraction - start time fraction)
              final durationDays = visibleEndJulian - visibleStartJulian;
              final durationWithTime = durationDays + (visibleEndTimeFraction - visibleStartTimeFraction);
              // Ensure minimum visible width
              final duration = durationWithTime < 0.1 ? 0.1 : durationWithTime;

              if (task.isAppointment) {
                // RTL: position from RIGHT with time-based offset
                // Appointments are positioned at their exact time within the day
                final circleRight = startOffset * dayWidth + (dayWidth * 0.5 * (1 - startTimeFraction * 2).abs()) - 16;

                return Positioned(
                  right: startOffset * dayWidth,
                  top: 20,
                  child: AppointmentCircle(
                    task: task,
                    onTap: () => _showAppointmentDetails(task),
                    onDoubleTap: () => _showEditTaskDialog(task),
                  ),
                );
              } else {
                // RTL: position bar from RIGHT with time-based precision
                final barRight = startOffset * dayWidth;
                final barWidth = duration * dayWidth;

                return Positioned(
                  right: barRight,
                  top: 20,
                  child: _ResizableTaskBar(
                    task: task,
                    width: barWidth,
                    maxWidth: constraints.maxWidth - barRight,
                    dayWidth: dayWidth,
                    onDoubleTap: () => _showEditTaskDialog(task),
                    onResized: (newStart, newEnd) => _onTaskResized(task, newStart, newEnd),
                  ),
                );
              }
            }),
          ],
        );
      },
    );
  }
}

/// Resizable and draggable task bar widget
/// Features:
/// - Drag handles on left/right edges to resize (adjust start/end times)
/// - Center drag to move the entire task
/// - Double-tap to edit
class _ResizableTaskBar extends StatefulWidget {
  final TaskEntity task;
  final double width;
  final double maxWidth;
  final double dayWidth;
  final VoidCallback? onDoubleTap;
  final void Function(DateTime newStart, DateTime newEnd)? onResized;

  const _ResizableTaskBar({
    required this.task,
    required this.width,
    required this.maxWidth,
    required this.dayWidth,
    this.onDoubleTap,
    this.onResized,
  });

  @override
  State<_ResizableTaskBar> createState() => _ResizableTaskBarState();
}

class _ResizableTaskBarState extends State<_ResizableTaskBar> {
  bool _isHovering = false;
  bool _isResizingStart = false;
  bool _isResizingEnd = false;
  double _resizeDelta = 0;
  double _positionOffset = 0; // For shifting position during start resize
  
  static const double _handleWidth = 8.0;
  static const double _minBarWidth = 20.0;

  Color get _color => widget.task.taskType == TaskType.generalTask
      ? TaskType.generalTask.color
      : widget.task.status.color;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = (widget.width + _resizeDelta).clamp(_minBarWidth, widget.maxWidth);
    
    // Apply position offset when resizing from start (right handle in RTL)
    // This makes the right edge move instead of the left edge
    return Transform.translate(
      offset: Offset(_positionOffset, 0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onDoubleTap: widget.onDoubleTap,
          child: SizedBox(
            width: effectiveWidth,
            height: 32,
            child: Stack(
            children: [
              // Main bar (draggable for moving)
              Positioned.fill(
                left: _handleWidth,
                right: _handleWidth,
                child: Draggable<TaskEntity>(
                  data: widget.task,
                  feedback: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(6),
                    child: _buildBarContent(effectiveWidth - _handleWidth * 2),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: _buildBarContent(effectiveWidth - _handleWidth * 2),
                  ),
                  child: Tooltip(
                    message: 'اسحب لنقل • انقر مرتين للتعديل',
                    child: _buildBarContent(effectiveWidth - _handleWidth * 2),
                  ),
                ),
              ),
              
              // Full bar background (for visual continuity)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: _color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Content overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.task.taskType.icon,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.task.name,
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
                  ),
                ),
              ),
              
              // Right resize handle (for RTL: adjusts START time)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: _buildResizeHandle(
                  isStart: true,
                  isActive: _isResizingStart,
                ),
              ),
              
              // Left resize handle (for RTL: adjusts END time)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _buildResizeHandle(
                  isStart: false,
                  isActive: _isResizingEnd,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildBarContent(double width) {
    return Container(
      width: width.clamp(_minBarWidth, widget.maxWidth),
      height: 32,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildResizeHandle({required bool isStart, required bool isActive}) {
    return GestureDetector(
      onHorizontalDragStart: (_) {
        setState(() {
          if (isStart) {
            _isResizingStart = true;
          } else {
            _isResizingEnd = true;
          }
          _resizeDelta = 0;
          _positionOffset = 0;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          // RTL layout: RIGHT = earlier dates, LEFT = later dates
          if (isStart) {
            // Right handle in RTL = start time
            // Dragging right (positive delta) = earlier start = wider bar
            _resizeDelta += details.delta.dx;
            // Shift position to make RIGHT edge move (not left edge)
            _positionOffset += details.delta.dx;
          } else {
            // Left handle in RTL = end time
            // Dragging left (negative delta) = later end = wider bar
            _resizeDelta -= details.delta.dx;
            // No position offset needed - left edge naturally moves
          }
        });
      },
      onHorizontalDragEnd: (_) {
        _applyResize(isStart);
        setState(() {
          _isResizingStart = false;
          _isResizingEnd = false;
          _resizeDelta = 0;
          _positionOffset = 0;
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _handleWidth,
          decoration: BoxDecoration(
            color: (_isHovering || isActive)
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: isStart ? Radius.zero : const Radius.circular(6),
              right: isStart ? const Radius.circular(6) : Radius.zero,
            ),
          ),
          child: (_isHovering || isActive)
              ? Center(
                  child: Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  void _applyResize(bool isStart) {
    if (widget.onResized == null) return;
    
    // Calculate the time change based on pixel delta
    // Each dayWidth pixels = 24 hours
    final hoursChanged = (_resizeDelta / widget.dayWidth) * 24;
    
    DateTime newStart = widget.task.startDate;
    DateTime newEnd = widget.task.endDate;
    
    if (isStart) {
      // Adjusting start time (right handle in RTL)
      // Positive delta (dragged right) = earlier start = subtract time
      newStart = widget.task.startDate.subtract(
        Duration(minutes: (hoursChanged * 60).round()),
      );
    } else {
      // Adjusting end time (left handle in RTL)
      // Positive delta (dragged left) = later end = add time
      newEnd = widget.task.endDate.add(
        Duration(minutes: (hoursChanged * 60).round()),
      );
    }
    
    // Ensure start is before end
    if (newStart.isBefore(newEnd)) {
      widget.onResized!(newStart, newEnd);
    }
  }
}
