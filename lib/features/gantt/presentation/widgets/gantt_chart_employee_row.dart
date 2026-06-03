import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../projects/domain/entities/team_member_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import 'gantt_chart_surface_support_widgets.dart';

class GanttEmployeeRow extends StatelessWidget {
  const GanttEmployeeRow({
    super.key,
    required this.member,
    required this.tasks,
    required this.startDate,
    required this.visibleDates,
    required this.isToday,
    required this.calculateTaskLanes,
    required this.onAppointmentDetails,
    required this.onEditTask,
    required this.onTaskDropped,
    required this.onTaskResized,
    required this.toJulianDay,
    required this.timeToFraction,
  });

  final TeamMemberEntity member;
  final List<TaskEntity> tasks;
  final DateTime startDate;
  final List<DateTime> visibleDates;
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
  final int Function(int year, int month, int day) toJulianDay;
  final double Function(DateTime dateTime) timeToFraction;

  @override
  Widget build(BuildContext context) {
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
    final laneCountValue = taskLanes.isEmpty
        ? 1
        : taskLanes.values.reduce((a, b) => a > b ? a : b) + 1;
    final rowHeight = 72.0 + ((laneCountValue - 1) * 38);

    return Container(
      height: rowHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
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
          ),
          Expanded(
            child: GanttBarsForEmployee(
              member: member,
              tasks: visibleTasks,
              startDate: startDate,
              visibleDates: visibleDates,
              taskLanes: taskLanes,
              onAppointmentDetails: onAppointmentDetails,
              onEditTask: onEditTask,
              onTaskDropped: onTaskDropped,
              onTaskResized: onTaskResized,
              toJulianDay: toJulianDay,
              timeToFraction: timeToFraction,
            ),
          ),
        ],
      ),
    );
  }
}
