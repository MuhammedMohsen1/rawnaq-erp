import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../projects/domain/entities/team_member_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../widgets/appointment_widgets.dart';
import '../widgets/gantt_filters_widget.dart';
import '../widgets/gantt_chart_surface_support_widgets.dart';

class GanttChartSurface extends StatelessWidget {
  const GanttChartSurface({
    super.key,
    required this.selectedOrientation,
    required this.selectedPeriod,
    required this.teamMembers,
    required this.tasks,
    required this.startDate,
    required this.horizontalZoom,
    required this.onPointerSignal,
    required this.horizontalTimelineScrollController,
    required this.shouldScrollToToday,
    required this.onScrolledToToday,
    required this.isToday,
    required this.calculateTaskLanes,
    required this.laneCount,
    required this.onAppointmentDetails,
    required this.onEditTask,
    required this.onTaskDropped,
    required this.onTaskResized,
    required this.isSameDate,
    required this.getViewDays,
    required this.toJulianDay,
    required this.timeToFraction,
  });

  final GanttLayoutOrientation selectedOrientation;
  final GanttTimePeriod selectedPeriod;
  final List<TeamMemberEntity> teamMembers;
  final List<TaskEntity> tasks;
  final DateTime startDate;
  final double horizontalZoom;
  final void Function(PointerSignalEvent event) onPointerSignal;
  final ScrollController horizontalTimelineScrollController;
  final bool shouldScrollToToday;
  final VoidCallback onScrolledToToday;
  final bool Function(DateTime date) isToday;
  final Map<String, int> Function(
    List<TaskEntity> tasks, {
    DateTime? visibleStart,
    DateTime? visibleEnd,
  })
  calculateTaskLanes;
  final int Function(Map<String, int> lanes) laneCount;
  final void Function(TaskEntity task) onAppointmentDetails;
  final void Function(TaskEntity task) onEditTask;
  final Future<void> Function(TaskEntity task, String assigneeId, DateTime date)
  onTaskDropped;
  final Future<void> Function(
    TaskEntity task,
    DateTime newStart,
    DateTime newEnd,
  )
  onTaskResized;
  final bool Function(DateTime a, DateTime b) isSameDate;
  final int Function() getViewDays;
  final int Function(int year, int month, int day) toJulianDay;
  final double Function(DateTime dateTime) timeToFraction;

  @override
  Widget build(BuildContext context) {
    return selectedOrientation == GanttLayoutOrientation.vertical
        ? _VerticalGanttChart(
            teamMembers: teamMembers,
            tasks: tasks,
            startDate: startDate,
            selectedPeriod: selectedPeriod,
            isToday: isToday,
            calculateTaskLanes: calculateTaskLanes,
            onAppointmentDetails: onAppointmentDetails,
            onEditTask: onEditTask,
            onTaskDropped: onTaskDropped,
            onTaskResized: onTaskResized,
            isSameDate: isSameDate,
            getViewDays: getViewDays,
          )
        : _HorizontalGanttChart(
            teamMembers: teamMembers,
            tasks: tasks,
            startDate: startDate,
            horizontalZoom: horizontalZoom,
            onPointerSignal: onPointerSignal,
            horizontalTimelineScrollController:
                horizontalTimelineScrollController,
            shouldScrollToToday: shouldScrollToToday,
            onScrolledToToday: onScrolledToToday,
            isToday: isToday,
            calculateTaskLanes: calculateTaskLanes,
            onAppointmentDetails: onAppointmentDetails,
            onEditTask: onEditTask,
            onTaskDropped: onTaskDropped,
            onTaskResized: onTaskResized,
            getViewDays: getViewDays,
            toJulianDay: toJulianDay,
            timeToFraction: timeToFraction,
          );
  }
}

class _HorizontalGanttChart extends StatefulWidget {
  const _HorizontalGanttChart({
    required this.teamMembers,
    required this.tasks,
    required this.startDate,
    required this.horizontalZoom,
    required this.onPointerSignal,
    required this.horizontalTimelineScrollController,
    required this.shouldScrollToToday,
    required this.onScrolledToToday,
    required this.isToday,
    required this.calculateTaskLanes,
    required this.onAppointmentDetails,
    required this.onEditTask,
    required this.onTaskDropped,
    required this.onTaskResized,
    required this.getViewDays,
    required this.toJulianDay,
    required this.timeToFraction,
  });

  final List<TeamMemberEntity> teamMembers;
  final List<TaskEntity> tasks;
  final DateTime startDate;
  final double horizontalZoom;
  final void Function(PointerSignalEvent event) onPointerSignal;
  final ScrollController horizontalTimelineScrollController;
  final bool shouldScrollToToday;
  final VoidCallback onScrolledToToday;
  final bool Function(DateTime date) isToday;
  final Map<String, int> Function(
    List<TaskEntity> tasks, {
    DateTime? visibleStart,
    DateTime? visibleEnd,
  })
  calculateTaskLanes;
  final void Function(TaskEntity task) onAppointmentDetails;
  final void Function(TaskEntity task) onEditTask;
  final Future<void> Function(TaskEntity task, String assigneeId, DateTime date)
  onTaskDropped;
  final Future<void> Function(
    TaskEntity task,
    DateTime newStart,
    DateTime newEnd,
  )
  onTaskResized;
  final int Function() getViewDays;
  final int Function(int year, int month, int day) toJulianDay;
  final double Function(DateTime dateTime) timeToFraction;

  @override
  State<_HorizontalGanttChart> createState() => _HorizontalGanttChartState();
}

class _HorizontalGanttChartState extends State<_HorizontalGanttChart> {
  final GlobalKey _todayHeaderKey = GlobalKey();
  final ScrollController _headerScrollController = ScrollController();
  bool _didScrollToToday = false;
  bool _isSyncingHorizontalScroll = false;

  @override
  void initState() {
    super.initState();
    widget.horizontalTimelineScrollController.addListener(_syncHeaderToBody);
    _headerScrollController.addListener(_syncBodyToHeader);
    _scheduleInitialTodayScroll();
  }

  @override
  void dispose() {
    widget.horizontalTimelineScrollController.removeListener(_syncHeaderToBody);
    _headerScrollController.removeListener(_syncBodyToHeader);
    _headerScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _HorizontalGanttChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.horizontalTimelineScrollController !=
        widget.horizontalTimelineScrollController) {
      oldWidget.horizontalTimelineScrollController.removeListener(
        _syncHeaderToBody,
      );
      widget.horizontalTimelineScrollController.addListener(_syncHeaderToBody);
    }
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.getViewDays() != widget.getViewDays()) {
      _didScrollToToday = false;
      _scheduleInitialTodayScroll();
    }
  }

  void _syncHeaderToBody() {
    _syncHorizontalControllers(
      source: widget.horizontalTimelineScrollController,
      target: _headerScrollController,
    );
  }

  void _syncBodyToHeader() {
    _syncHorizontalControllers(
      source: _headerScrollController,
      target: widget.horizontalTimelineScrollController,
    );
  }

  void _syncHorizontalControllers({
    required ScrollController source,
    required ScrollController target,
  }) {
    if (_isSyncingHorizontalScroll ||
        !source.hasClients ||
        !target.hasClients) {
      return;
    }
    final targetPosition = target.position;
    final nextOffset = source.offset.clamp(
      targetPosition.minScrollExtent,
      targetPosition.maxScrollExtent,
    );
    if ((target.offset - nextOffset).abs() < 0.5) return;
    _isSyncingHorizontalScroll = true;
    target.jumpTo(nextOffset);
    _isSyncingHorizontalScroll = false;
  }

  void _scheduleInitialTodayScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didScrollToToday) return;
      if (!widget.shouldScrollToToday) return;
      final todayContext = _todayHeaderKey.currentContext;
      if (todayContext == null) return;
      _didScrollToToday = true;
      widget.onScrolledToToday();
      Scrollable.ensureVisible(
        todayContext,
        alignment: 0.5,
        duration: Duration.zero,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayDays = widget.getViewDays();
    final visibleDates = _buildWorkDates(widget.startDate, displayDays);
    const employeeColumnWidth = 220.0;
    final dayWidth = 60.0 * widget.horizontalZoom;
    final timelineWidth = displayDays * dayWidth;
    final tasksByEmployee = {
      for (final member in widget.teamMembers)
        member.id: widget.tasks
            .where((task) => task.assigneeId == member.id)
            .toList(),
    };

    final rows = widget.teamMembers.map((member) {
      final memberTasks = tasksByEmployee[member.id] ?? const <TaskEntity>[];
      final rowMetrics = _HorizontalRowMetrics.calculate(
        memberTasks,
        widget.startDate,
        visibleDates,
        widget.calculateTaskLanes,
      );
      return _HorizontalRowData(
        member: member,
        tasks: rowMetrics.visibleTasks,
        taskLanes: rowMetrics.taskLanes,
        height: rowMetrics.height,
      );
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            _HorizontalEmployeeHeader(width: employeeColumnWidth),
            Expanded(
              child: SingleChildScrollView(
                key: const PageStorageKey<String>(
                  'gantt-horizontal-timeline-header-scroll',
                ),
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                child: Listener(
                  onPointerSignal: widget.onPointerSignal,
                  child: SizedBox(
                    width: timelineWidth,
                    child: _HorizontalDateHeader(
                      visibleDates: visibleDates,
                      dayWidth: dayWidth,
                      isToday: widget.isToday,
                      todayKey: _todayHeaderKey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: employeeColumnWidth,
                  child: Column(
                    children: rows
                        .map(
                          (row) => _HorizontalEmployeeCell(
                            member: row.member,
                            height: row.height,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    controller: widget.horizontalTimelineScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: widget.horizontalTimelineScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Listener(
                        onPointerSignal: widget.onPointerSignal,
                        child: SizedBox(
                          width: timelineWidth,
                          child: Column(
                            children: rows
                                .map(
                                  (row) => SizedBox(
                                    height: row.height,
                                    child: GanttBarsForEmployee(
                                      member: row.member,
                                      tasks: row.tasks,
                                      startDate: widget.startDate,
                                      visibleDates: visibleDates,
                                      taskLanes: row.taskLanes,
                                      onAppointmentDetails:
                                          widget.onAppointmentDetails,
                                      onEditTask: widget.onEditTask,
                                      onTaskDropped: widget.onTaskDropped,
                                      onTaskResized: widget.onTaskResized,
                                      toJulianDay: widget.toJulianDay,
                                      timeToFraction: widget.timeToFraction,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<DateTime> _buildWorkDates(DateTime startDate, int count) {
    final dates = <DateTime>[];
    var offset = 0;
    while (dates.length < count) {
      final date = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + offset,
      );
      if (date.weekday != DateTime.friday) {
        dates.add(date);
      }
      offset++;
    }
    return dates;
  }
}

class _HorizontalRowData {
  const _HorizontalRowData({
    required this.member,
    required this.tasks,
    required this.taskLanes,
    required this.height,
  });

  final TeamMemberEntity member;
  final List<TaskEntity> tasks;
  final Map<String, int> taskLanes;
  final double height;
}

class _HorizontalRowMetrics {
  const _HorizontalRowMetrics({
    required this.visibleTasks,
    required this.taskLanes,
    required this.height,
  });

  final List<TaskEntity> visibleTasks;
  final Map<String, int> taskLanes;
  final double height;

  static _HorizontalRowMetrics calculate(
    List<TaskEntity> tasks,
    DateTime startDate,
    List<DateTime> visibleDates,
    Map<String, int> Function(
      List<TaskEntity> tasks, {
      DateTime? visibleStart,
      DateTime? visibleEnd,
    })
    calculateTaskLanes,
  ) {
    final endDate = DateTime(
      visibleDates.last.year,
      visibleDates.last.month,
      visibleDates.last.day + 1,
    );
    final visibleTasks = tasks
        .where(
          (task) =>
              task.endDate.isAfter(startDate) &&
              task.startDate.isBefore(endDate),
        )
        .toList();
    final taskLanes = calculateTaskLanes(
      visibleTasks,
      visibleStart: startDate,
      visibleEnd: endDate,
    );
    final laneCount = taskLanes.isEmpty
        ? 1
        : taskLanes.values.reduce((a, b) => a > b ? a : b) + 1;
    return _HorizontalRowMetrics(
      visibleTasks: visibleTasks,
      taskLanes: taskLanes,
      height: 72.0 + ((laneCount - 1) * 38),
    );
  }
}

class _HorizontalEmployeeHeader extends StatelessWidget {
  const _HorizontalEmployeeHeader({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
      decoration: const BoxDecoration(
        color: AppColors.tableHeader,
        borderRadius: BorderRadius.only(topRight: Radius.circular(12)),
        border: Border(left: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Text('الموظفين', style: AppTextStyles.tableHeader),
    );
  }
}

class _HorizontalEmployeeCell extends StatelessWidget {
  const _HorizontalEmployeeCell({required this.member, required this.height});

  final TeamMemberEntity member;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          left: BorderSide(color: AppColors.border, width: 1),
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              member.name.isEmpty ? '-' : member.name.substring(0, 1),
              style: const TextStyle(
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
    );
  }
}

class _VerticalGanttChart extends StatelessWidget {
  const _VerticalGanttChart({
    required this.teamMembers,
    required this.tasks,
    required this.startDate,
    required this.selectedPeriod,
    required this.isToday,
    required this.calculateTaskLanes,
    required this.onAppointmentDetails,
    required this.onEditTask,
    required this.onTaskDropped,
    required this.onTaskResized,
    required this.isSameDate,
    required this.getViewDays,
  });

  final List<TeamMemberEntity> teamMembers;
  final List<TaskEntity> tasks;
  final DateTime startDate;
  final GanttTimePeriod selectedPeriod;
  final bool Function(DateTime date) isToday;
  final Map<String, int> Function(
    List<TaskEntity> tasks, {
    DateTime? visibleStart,
    DateTime? visibleEnd,
  })
  calculateTaskLanes;
  final void Function(TaskEntity task) onAppointmentDetails;
  final void Function(TaskEntity task) onEditTask;
  final Future<void> Function(TaskEntity task, String assigneeId, DateTime date)
  onTaskDropped;
  final Future<void> Function(
    TaskEntity task,
    DateTime newStart,
    DateTime newEnd,
  )
  onTaskResized;
  final bool Function(DateTime a, DateTime b) isSameDate;
  final int Function() getViewDays;

  @override
  Widget build(BuildContext context) {
    final displayDays = getViewDays();
    const dateRailWidth = 118.0;
    const employeeColumnWidth = 220.0;
    final rowHeight = selectedPeriod == GanttTimePeriod.today ? 168.0 : 112.0;
    final chartWidth =
        dateRailWidth + (teamMembers.length * employeeColumnWidth);
    final chartHeight = displayDays * rowHeight;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth,
        child: Column(
          children: [
            _VerticalMembersHeader(
              dateRailWidth: dateRailWidth,
              employeeColumnWidth: employeeColumnWidth,
              teamMembers: teamMembers,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: chartHeight,
                  child: Row(
                    children: [
                      SizedBox(
                        width: dateRailWidth,
                        child: Column(
                          children: List.generate(displayDays, (index) {
                            final date = DateTime(
                              startDate.year,
                              startDate.month,
                              startDate.day + index,
                            );
                            return SizedBox(
                              height: rowHeight,
                              child: _VerticalDateCell(
                                date: date,
                                width: dateRailWidth,
                                isToday: isToday(date),
                              ),
                            );
                          }),
                        ),
                      ),
                      ...teamMembers.map((member) {
                        final memberTasks = tasks
                            .where((task) => task.assigneeId == member.id)
                            .toList();
                        return SizedBox(
                          width: employeeColumnWidth,
                          child: _VerticalEmployeeTimeline(
                            member: member,
                            tasks: memberTasks,
                            startDate: startDate,
                            displayDays: displayDays,
                            rowHeight: rowHeight,
                            isToday: isToday,
                            calculateTaskLanes: calculateTaskLanes,
                            onAppointmentDetails: onAppointmentDetails,
                            onEditTask: onEditTask,
                            onTaskDropped: onTaskDropped,
                            onTaskResized: onTaskResized,
                            isSameDate: isSameDate,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalDateHeader extends StatelessWidget {
  const _HorizontalDateHeader({
    required this.visibleDates,
    required this.dayWidth,
    required this.isToday,
    required this.todayKey,
  });

  final List<DateTime> visibleDates;
  final double dayWidth;
  final bool Function(DateTime date) isToday;
  final GlobalKey todayKey;

  @override
  Widget build(BuildContext context) {
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
        children: visibleDates.map((date) {
          final today = isToday(date);
          final weekStart = _isVisibleWeekStart(date);
          return SizedBox(
            width: dayWidth,
            child: Container(
              key: today ? todayKey : null,
              decoration: BoxDecoration(
                color: today ? AppColors.primary.withValues(alpha: 0.1) : null,
                border: Border(
                  left: BorderSide(
                    color: weekStart
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.border,
                    width: weekStart ? 2 : 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayFormat.format(date),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: today
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: today ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: today ? AppColors.primary : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        dateFormat.format(date),
                        style: TextStyle(
                          color: today
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
        }).toList(),
      ),
    );
  }

  bool _isVisibleWeekStart(DateTime date) {
    return date.weekday == DateTime.thursday;
  }
}

class _VerticalMembersHeader extends StatelessWidget {
  const _VerticalMembersHeader({
    required this.dateRailWidth,
    required this.employeeColumnWidth,
    required this.teamMembers,
  });

  final double dateRailWidth;
  final double employeeColumnWidth;
  final List<TeamMemberEntity> teamMembers;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
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
            width: dateRailWidth,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.border)),
            ),
            child: Text('التاريخ', style: AppTextStyles.tableHeader),
          ),
          ...teamMembers.map(
            (member) => SizedBox(
              width: employeeColumnWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        member.name.isEmpty ? '-' : member.name.substring(0, 1),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: AppTextStyles.tableCellBold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDateCell extends StatelessWidget {
  const _VerticalDateCell({
    required this.date,
    required this.width,
    required this.isToday,
  });

  final DateTime date;
  final double width;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('EEEE', 'ar');
    final dateFormat = DateFormat('d MMM', 'ar');
    final isWeekend = date.weekday == DateTime.friday;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary.withValues(alpha: 0.1)
            : isWeekend
            ? AppColors.surfaceColor.withValues(alpha: 0.28)
            : AppColors.cardBackground,
        border: const Border(
          left: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dayFormat.format(date),
            style: AppTextStyles.labelSmall.copyWith(
              color: isToday ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isToday ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              dateFormat.format(date),
              style: AppTextStyles.tableCellBold.copyWith(
                color: isToday
                    ? AppColors.scaffoldBackground
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalEmployeeTimeline extends StatelessWidget {
  const _VerticalEmployeeTimeline({
    required this.member,
    required this.tasks,
    required this.startDate,
    required this.displayDays,
    required this.rowHeight,
    required this.isToday,
    required this.calculateTaskLanes,
    required this.onAppointmentDetails,
    required this.onEditTask,
    required this.onTaskDropped,
    required this.onTaskResized,
    required this.isSameDate,
  });

  final TeamMemberEntity member;
  final List<TaskEntity> tasks;
  final DateTime startDate;
  final int displayDays;
  final double rowHeight;
  final bool Function(DateTime date) isToday;
  final Map<String, int> Function(
    List<TaskEntity> tasks, {
    DateTime? visibleStart,
    DateTime? visibleEnd,
  })
  calculateTaskLanes;
  final void Function(TaskEntity task) onAppointmentDetails;
  final void Function(TaskEntity task) onEditTask;
  final Future<void> Function(TaskEntity task, String assigneeId, DateTime date)
  onTaskDropped;
  final Future<void> Function(
    TaskEntity task,
    DateTime newStart,
    DateTime newEnd,
  )
  onTaskResized;
  final bool Function(DateTime a, DateTime b) isSameDate;

  @override
  Widget build(BuildContext context) {
    final chartEnd = DateTime(
      startDate.year,
      startDate.month,
      startDate.day + displayDays,
    );
    final visibleTasks = tasks
        .where(
          (task) =>
              task.endDate.isAfter(startDate) &&
              task.startDate.isBefore(chartEnd),
        )
        .toList();
    final taskLanes = calculateTaskLanes(
      visibleTasks,
      visibleStart: startDate,
      visibleEnd: chartEnd,
    );
    final laneCountValue = taskLanes.isEmpty
        ? 1
        : taskLanes.values.reduce((a, b) => a > b ? a : b) + 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final laneGap = laneCountValue > 1 ? 6.0 : 0.0;
        final laneWidth =
            (constraints.maxWidth - 20 - ((laneCountValue - 1) * laneGap)) /
            laneCountValue;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Column(
              children: List.generate(displayDays, (index) {
                final date = DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day + index,
                );
                return SizedBox(
                  height: rowHeight,
                  child: DragTarget<TaskEntity>(
                    onWillAcceptWithDetails: (_) => true,
                    onAcceptWithDetails: (details) =>
                        onTaskDropped(details.data, member.id, date),
                    builder: (context, candidateData, rejectedData) {
                      final hovering = candidateData.isNotEmpty;
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: hovering
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : isToday(date)
                              ? AppColors.primary.withValues(alpha: 0.035)
                              : date.weekday == DateTime.friday
                              ? AppColors.surfaceColor.withValues(alpha: 0.12)
                              : AppColors.cardBackground,
                          border: const Border(
                            left: BorderSide(color: AppColors.border),
                            bottom: BorderSide(color: AppColors.divider),
                          ),
                        ),
                        child: hovering
                            ? Center(
                                child: Icon(
                                  Icons.add_circle,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                );
              }),
            ),
            ...visibleTasks.map((task) {
              final visibleStart = task.startDate.isBefore(startDate)
                  ? startDate
                  : task.startDate;
              final visibleEnd = task.endDate.isAfter(chartEnd)
                  ? chartEnd
                  : task.endDate;
              final startOffsetDays =
                  visibleStart.difference(startDate).inMinutes / (24 * 60);
              final durationDays =
                  visibleEnd.difference(visibleStart).inMinutes / (24 * 60);
              final top = (startOffsetDays * rowHeight) + 10;
              final height = (durationDays * rowHeight - 20).clamp(
                36.0,
                rowHeight * displayDays,
              );
              final lane = taskLanes[task.id] ?? 0;
              final laneLeft = 10 + (lane * (laneWidth + laneGap));
              if (task.isAppointment) {
                return Positioned(
                  top: top,
                  left: laneLeft,
                  width: laneWidth,
                  child: Align(
                    alignment: Alignment.center,
                    child: AppointmentCircle(
                      task: task,
                      onTap: () => onAppointmentDetails(task),
                      onDoubleTap: () => onEditTask(task),
                    ),
                  ),
                );
              }
              return Positioned(
                top: top,
                left: laneLeft,
                width: laneWidth,
                height: height,
                child: Draggable<TaskEntity>(
                  data: task,
                  feedback: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: laneWidth,
                      height: height,
                      child: GanttVerticalResizableTaskChip(
                        task: task,
                        color: ganttTaskColor(task),
                        compactMeta:
                            '${task.formattedStartTime} - ${task.formattedEndTime}',
                        rowHeight: rowHeight,
                        canResizeStart: isSameDate(
                          visibleStart,
                          task.startDateOnly,
                        ),
                        canResizeEnd: isSameDate(visibleEnd, task.endDateOnly),
                        onResized: onTaskResized,
                      ),
                    ),
                  ),
                  childWhenDragging: const Opacity(
                    opacity: 0.35,
                    child: SizedBox.expand(),
                  ),
                  child: GestureDetector(
                    onDoubleTap: () => onEditTask(task),
                    child: Tooltip(
                      message: 'اسحب لنقل • انقر مرتين للتعديل',
                      child: GanttVerticalResizableTaskChip(
                        task: task,
                        color: ganttTaskColor(task),
                        compactMeta:
                            '${task.formattedStartTime} - ${task.formattedEndTime}',
                        rowHeight: rowHeight,
                        canResizeStart: isSameDate(
                          visibleStart,
                          task.startDateOnly,
                        ),
                        canResizeEnd: isSameDate(visibleEnd, task.endDateOnly),
                        onResized: onTaskResized,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
