import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../projects/data/datasources/projects_api_datasource.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/enums/task_status.dart';
import '../../../tasks/domain/enums/task_type.dart';
import '../../../tasks/data/datasources/tasks_api_datasource.dart';
import '../../../projects/domain/entities/team_member_entity.dart';
import '../widgets/gantt_filters_widget.dart';
import '../widgets/add_task_dialog_simple.dart';
import '../widgets/appointment_widgets.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/gantt_chart_widgets.dart';

/// Gantt Chart page for task visualization
class GanttChartPage extends StatefulWidget {
  const GanttChartPage({super.key});

  @override
  State<GanttChartPage> createState() => _GanttChartPageState();
}

class _GanttChartPageState extends State<GanttChartPage> {
  final TasksApiDataSource _dataSource = TasksApiDataSource();
  final ProjectsApiDataSource _projectsDataSource = ProjectsApiDataSource();

  GanttTimePeriod _selectedPeriod = GanttTimePeriod.week;
  GanttLayoutOrientation _selectedOrientation =
      GanttLayoutOrientation.horizontal;
  bool _showTeamTasks = true;
  String? _selectedMemberId;
  bool _isDraftPanelExpanded = true;
  bool _isLoading = true;
  String? _errorMessage;

  List<TaskEntity> _tasks = [];
  List<TaskEntity> _draftTasks = [];
  List<TeamMemberEntity> _teamMembers = [];
  List<TeamMemberEntity> _overloadedMembers = [];
  List<String> _delayedProjects = [];
  List<Map<String, String>> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _teamMembers = await _dataSource.getTeamMembers();
      _projects = await _loadProjectsForTasks();
      await _applyFilters(setLoading: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل المهام';
      });
    }
  }

  Future<List<Map<String, String>>> _loadProjectsForTasks() async {
    try {
      final response = await _projectsDataSource.getProjects(limit: 100);
      final projects = response['projects'] as List<dynamic>;
      return projects
          .map((json) {
            final map = json as Map<String, dynamic>;
            return {
              'id': map['id'] as String,
              'name': map['name'] as String? ?? '',
            };
          })
          .where((project) => project['name']!.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _applyFilters({bool setLoading = true}) async {
    if (setLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final startDate = _getStartDate();
      final endDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + _getViewDays(),
      );
      final assigneeId = _showTeamTasks ? _selectedMemberId : null;
      final tasks = _showTeamTasks
          ? await _dataSource.getTasks(
              assigneeId: assigneeId,
              startDate: startDate,
              endDate: endDate,
              includeDrafts: true,
            )
          : await _dataSource.getMyTasks(
              startDate: startDate,
              endDate: endDate,
            );

      if (!mounted) return;
      setState(() {
        _tasks = tasks
            .where((t) => !t.isDraft && t.assigneeId != null)
            .toList();
        _draftTasks = tasks
            .where((t) => t.isDraft || t.assigneeId == null)
            .toList();
        _overloadedMembers = _calculateOverloadedMembers(_tasks);
        _delayedProjects = _calculateDelayedProjects(_tasks);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل المهام';
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedPeriod = GanttTimePeriod.week;
      _showTeamTasks = true;
      _selectedMemberId = null;
    });
    _applyFilters();
  }

  List<TeamMemberEntity> _calculateOverloadedMembers(List<TaskEntity> tasks) {
    final counts = <String, int>{};
    for (final task in tasks) {
      if (task.status != TaskStatus.completed && task.assigneeId != null) {
        counts[task.assigneeId!] = (counts[task.assigneeId!] ?? 0) + 1;
      }
    }

    return _teamMembers.where((m) => (counts[m.id] ?? 0) > 3).toList();
  }

  List<String> _calculateDelayedProjects(List<TaskEntity> tasks) {
    return tasks
        .where(
          (task) =>
              task.status == TaskStatus.delayed && task.projectName != null,
        )
        .map((task) => task.projectName!)
        .toSet()
        .toList();
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
        final adjustedStartMonth = startMonth <= 0
            ? startMonth + 12
            : startMonth;
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
      builder: (dialogContext) => AddTaskDialogSimple(
        projects: _projects,
        onTaskAdded: (task) {
          bool wasAdjusted = false;
          _dataSource.createTask(task).then((createdTask) {
            wasAdjusted = createdTask.wasAdjusted;
            _applyFilters();

            if (!mounted) return;
            if (wasAdjusted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إضافة المهمة: ${task.name}\nتم تعديل الوقت تلقائياً لتجنب التعارض',
                  ),
                  backgroundColor: AppColors.warning,
                  duration: const Duration(seconds: 4),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إضافة المهمة: ${task.name}'),
                  backgroundColor: AppColors.statusOnHold,
                ),
              );
            }
          });
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

  Future<void> _onTaskDropped(
    TaskEntity task,
    String assigneeId,
    DateTime date,
  ) async {
    final updatedTask = task.isDraft || task.assigneeId == null
        ? await _dataSource.assignTask(
            task.id,
            assigneeId: assigneeId,
            startDate: _datePreservingTaskTime(date, task.startDate),
          )
        : await _dataSource.scheduleTask(
            task.id,
            startDate: _datePreservingTaskTime(date, task.startDate),
            assigneeId: assigneeId,
          );

    await _applyFilters();

    final action = (task.isDraft || task.assigneeId == null)
        ? 'تم تعيين المهمة'
        : (task.assigneeId != assigneeId
              ? 'تم نقل المهمة'
              : 'تم تحديث تاريخ المهمة');

    if (updatedTask.wasAdjusted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$action: ${task.name}\nتم تعديل الوقت تلقائياً لتجنب التعارض',
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action: ${task.name}'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    }
  }

  /// Called when a task is resized by dragging its edges
  Future<void> _onTaskResized(
    TaskEntity task,
    DateTime newStart,
    DateTime newEnd,
  ) async {
    // Skip conflict check for appointments
    if (task.taskType == TaskType.appointment || task.assigneeId == null) {
      await _dataSource.scheduleTask(
        task.id,
        startDate: newStart,
        endDate: newEnd,
      );
      await _applyFilters();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تعديل مدة المهمة: ${task.name}'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
      return;
    }

    final updatedTask = await _dataSource.scheduleTask(
      task.id,
      startDate: newStart,
      endDate: newEnd,
      assigneeId: task.assigneeId,
    );
    await _applyFilters();

    final wasAdjusted = updatedTask.wasAdjusted;
    if (wasAdjusted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تعديل مدة المهمة: ${task.name}\nتم تعديل الوقت تلقائياً لتجنب التعارض',
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تعديل مدة المهمة: ${task.name}'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    }
  }

  DateTime _datePreservingTaskTime(DateTime date, DateTime timeSource) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeSource.hour,
      timeSource.minute,
      timeSource.second,
    );
  }

  void _showEditTaskDialog(TaskEntity task) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditTaskDialog(
        task: task,
        teamMembers: _teamMembers,
        onTaskUpdated: (updatedTask) async {
          final savedTask = await _dataSource.updateTask(updatedTask);
          await _applyFilters();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                savedTask.wasAdjusted
                    ? 'تم تحديث المهمة: ${updatedTask.name}\nتم تعديل الوقت تلقائياً لتجنب التعارض'
                    : 'تم تحديث المهمة: ${updatedTask.name}',
              ),
              backgroundColor: savedTask.wasAdjusted
                  ? AppColors.warning
                  : AppColors.statusCompleted,
              duration: savedTask.wasAdjusted
                  ? const Duration(seconds: 4)
                  : const Duration(seconds: 3),
            ),
          );
        },
        onTaskDeleted: () {
          _dataSource.deleteTask(task.id).then((_) => _applyFilters());
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
        child: GanttChartPageBody(
          selectedPeriod: _selectedPeriod,
          selectedOrientation: _selectedOrientation,
          showTeamTasks: _showTeamTasks,
          selectedMemberId: _selectedMemberId,
          teamMembers: _teamMembers,
          draftTasks: _draftTasks,
          overloadedMembers: _overloadedMembers,
          delayedProjects: _delayedProjects,
          isDraftPanelExpanded: _isDraftPanelExpanded,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          startDate: startDate,
          tasks: _tasks,
          onPeriodChanged: (period) {
            setState(() => _selectedPeriod = period);
          },
          onOrientationChanged: (orientation) {
            setState(() => _selectedOrientation = orientation);
          },
          onTeamTasksChanged: (showTeam) {
            setState(() => _showTeamTasks = showTeam);
          },
          onMemberChanged: (memberId) {
            setState(() => _selectedMemberId = memberId);
          },
          onApplyFilters: _applyFilters,
          onClearFilters: _clearFilters,
          onToggleDraftPanel: () =>
              setState(() => _isDraftPanelExpanded = !_isDraftPanelExpanded),
          onAddTaskPressed: _showAddTaskDialog,
          onRetry: _loadData,
          onAppointmentDetails: _showAppointmentDetails,
          onEditTask: _showEditTaskDialog,
          onTaskDropped: _onTaskDropped,
          onTaskResized: _onTaskResized,
          onTaskUpdated: _applyFilters,
          onTaskCreated: _dataSource.createTask,
          onTaskDeleted: _dataSource.deleteTask,
          onUpdateTask: _dataSource.updateTask,
          datePreservingTaskTime: _datePreservingTaskTime,
          isToday: _isToday,
          isSameDate: _isSameDate,
          getViewDays: _getViewDays,
          getStartDate: _getStartDate,
          calculateTaskLanes: _calculateTaskLanes,
          laneCount: _laneCount,
          daysInMonth: _daysInMonth,
          toJulianDay: _toJulianDay,
          timeToFraction: _timeToFraction,
        ),
      ),
    );
  }
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Convert a date to Julian day number (accurate calendar calculation)
  int _toJulianDay(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
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

  Map<String, int> _calculateTaskLanes(
    List<TaskEntity> tasks, {
    DateTime? visibleStart,
    DateTime? visibleEnd,
  }) {
    final sortedTasks = [...tasks]
      ..sort((a, b) {
        final startCompare = a.startDate.compareTo(b.startDate);
        if (startCompare != 0) return startCompare;
        return a.endDate.compareTo(b.endDate);
      });

    final laneEnds = <DateTime>[];
    final lanes = <String, int>{};

    for (final task in sortedTasks) {
      final laneStart =
          visibleStart != null && task.startDate.isBefore(visibleStart)
          ? visibleStart
          : task.startDate;
      final laneEnd = visibleEnd != null && task.endDate.isAfter(visibleEnd)
          ? visibleEnd
          : task.endDate;

      if (!laneStart.isBefore(laneEnd)) continue;

      var laneIndex = laneEnds.indexWhere(
        (currentLaneEnd) => !laneStart.isBefore(currentLaneEnd),
      );
      if (laneIndex == -1) {
        laneIndex = laneEnds.length;
        laneEnds.add(laneEnd);
      } else {
        laneEnds[laneIndex] = laneEnd;
      }
      lanes[task.id] = laneIndex;
    }

    return lanes;
  }

  int _laneCount(Map<String, int> lanes) {
    if (lanes.isEmpty) return 1;
    return lanes.values.reduce((a, b) => a > b ? a : b) + 1;
  }
}
