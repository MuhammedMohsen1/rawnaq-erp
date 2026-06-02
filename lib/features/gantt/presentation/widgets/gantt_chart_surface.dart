import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../projects/domain/entities/team_member_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/enums/task_status.dart';
import '../../../tasks/domain/enums/task_type.dart';
import '../widgets/appointment_widgets.dart';
import '../widgets/gantt_filters_widget.dart';
import '../widgets/gantt_chart_surface_support_widgets.dart';
import '../widgets/gantt_chart_employee_row.dart';

class GanttChartSurface extends StatelessWidget {
  const GanttChartSurface({
    super.key,
    required this.selectedOrientation,
    required this.selectedPeriod,
    required this.teamMembers,
    required this.tasks,
    required this.startDate,
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

class _HorizontalGanttChart extends StatelessWidget {
  const _HorizontalGanttChart({
    required this.teamMembers,
    required this.tasks,
    required this.startDate,
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
  Widget build(BuildContext context) {
    final displayDays = getViewDays();
    final tasksByEmployee = {
      for (final member in teamMembers)
        member.id: tasks.where((task) => task.assigneeId == member.id).toList(),
    };
    final needsHorizontalScroll = displayDays > 14;
    Widget chartContent = Column(
      children: [
        _HorizontalDateHeader(
          startDate: startDate,
          displayDays: displayDays,
          isToday: isToday,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: teamMembers.length,
            itemBuilder: (context, index) {
              final member = teamMembers[index];
              final memberTasks = tasksByEmployee[member.id] ?? const [];
              return GanttEmployeeRow(
                member: member,
                tasks: memberTasks,
                startDate: startDate,
                displayDays: displayDays,
                isToday: isToday,
                calculateTaskLanes: calculateTaskLanes,
                onAppointmentDetails: onAppointmentDetails,
                onEditTask: onEditTask,
                onTaskDropped: onTaskDropped,
                onTaskResized: onTaskResized,
                toJulianDay: toJulianDay,
                timeToFraction: timeToFraction,
              );
            },
          ),
        ),
      ],
    );
    if (needsHorizontalScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 200.0 + (displayDays * 60.0),
          child: chartContent,
        ),
      );
    }
    return chartContent;
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
    required this.startDate,
    required this.displayDays,
    required this.isToday,
  });

  final DateTime startDate;
  final int displayDays;
  final bool Function(DateTime date) isToday;

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
            child: Text('الموظفين', style: AppTextStyles.tableHeader),
          ),
          Expanded(
            child: Row(
              children: List.generate(displayDays, (i) {
                final date = DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day + i,
                );
                final today = isToday(date);
                final weekend = date.weekday == DateTime.friday;
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: today
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : (weekend
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
                            color: today
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: today
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
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
              }),
            ),
          ),
        ],
      ),
    );
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
                        color: task.taskType == TaskType.generalTask
                            ? TaskType.generalTask.color
                            : task.status.color,
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
                        color: task.taskType == TaskType.generalTask
                            ? TaskType.generalTask.color
                            : task.status.color,
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
