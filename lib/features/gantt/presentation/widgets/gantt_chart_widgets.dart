import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../projects/domain/entities/team_member_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/enums/task_status.dart';
import '../widgets/gantt_filters_widget.dart';
import '../widgets/gantt_chart_surface.dart';
import '../widgets/gantt_chart_surface_support_widgets.dart';

class GanttChartPageBody extends StatelessWidget {
  const GanttChartPageBody({
    super.key,
    required this.selectedPeriod,
    required this.selectedOrientation,
    required this.horizontalZoom,
    required this.showTeamTasks,
    required this.selectedMemberId,
    required this.teamMembers,
    required this.draftTasks,
    required this.overloadedMembers,
    required this.delayedProjects,
    required this.isDraftPanelExpanded,
    required this.isLoading,
    required this.errorMessage,
    required this.startDate,
    required this.horizontalTimelineScrollController,
    required this.shouldScrollTimelineToToday,
    required this.onTimelineScrolledToToday,
    required this.tasks,
    required this.onPeriodChanged,
    required this.onOrientationChanged,
    required this.onTeamTasksChanged,
    required this.onMemberChanged,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
    required this.onPointerSignal,
    required this.onApplyFilters,
    required this.onClearFilters,
    required this.onToggleDraftPanel,
    required this.onAddTaskPressed,
    required this.onRetry,
    required this.onAppointmentDetails,
    required this.onEditTask,
    required this.onTaskDropped,
    required this.onTaskResized,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.onUpdateTask,
    required this.datePreservingTaskTime,
    required this.isToday,
    required this.isSameDate,
    required this.getViewDays,
    required this.getStartDate,
    required this.calculateTaskLanes,
    required this.laneCount,
    required this.daysInMonth,
    required this.toJulianDay,
    required this.timeToFraction,
  });

  final GanttTimePeriod selectedPeriod;
  final GanttLayoutOrientation selectedOrientation;
  final double horizontalZoom;
  final bool showTeamTasks;
  final String? selectedMemberId;
  final List<TeamMemberEntity> teamMembers;
  final List<TaskEntity> draftTasks;
  final List<TeamMemberEntity> overloadedMembers;
  final List<String> delayedProjects;
  final bool isDraftPanelExpanded;
  final bool isLoading;
  final String? errorMessage;
  final DateTime startDate;
  final ScrollController horizontalTimelineScrollController;
  final bool shouldScrollTimelineToToday;
  final VoidCallback onTimelineScrolledToToday;
  final List<TaskEntity> tasks;
  final ValueChanged<GanttTimePeriod> onPeriodChanged;
  final ValueChanged<GanttLayoutOrientation> onOrientationChanged;
  final ValueChanged<bool> onTeamTasksChanged;
  final ValueChanged<String?> onMemberChanged;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;
  final void Function(PointerSignalEvent event) onPointerSignal;
  final VoidCallback onApplyFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onToggleDraftPanel;
  final VoidCallback onAddTaskPressed;
  final VoidCallback onRetry;
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
  final Future<void> Function() onTaskUpdated;
  final Future<TaskEntity> Function(TaskEntity task) onTaskCreated;
  final Future<void> Function(String taskId) onTaskDeleted;
  final Future<TaskEntity> Function(TaskEntity task) onUpdateTask;
  final DateTime Function(DateTime date, DateTime timeSource)
  datePreservingTaskTime;
  final bool Function(DateTime date) isToday;
  final bool Function(DateTime a, DateTime b) isSameDate;
  final int Function() getViewDays;
  final DateTime Function() getStartDate;
  final Map<String, int> Function(
    List<TaskEntity> tasks, {
    DateTime? visibleStart,
    DateTime? visibleEnd,
  })
  calculateTaskLanes;
  final int Function(Map<String, int> lanes) laneCount;
  final int Function(int year, int month) daysInMonth;
  final int Function(int year, int month, int day) toJulianDay;
  final double Function(DateTime dateTime) timeToFraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('توزيع المهام', style: AppTextStyles.pageTitle),
        const SizedBox(height: 24),
        GanttFiltersWidget(
          selectedPeriod: selectedPeriod,
          selectedOrientation: selectedOrientation,
          showTeamTasks: showTeamTasks,
          selectedMemberId: selectedMemberId,
          teamMembers: teamMembers,
          zoomLevel: horizontalZoom,
          onPeriodChanged: onPeriodChanged,
          onOrientationChanged: onOrientationChanged,
          onTeamTasksChanged: onTeamTasksChanged,
          onMemberChanged: onMemberChanged,
          onZoomIn: onZoomIn,
          onZoomOut: onZoomOut,
          onResetZoom: onResetZoom,
          onApplyFilters: onApplyFilters,
          onClearFilters: onClearFilters,
        ),
        const SizedBox(height: 12),
        GanttCompactInfoBar(
          draftTasks: draftTasks,
          overloadedMembers: overloadedMembers,
          delayedProjects: delayedProjects,
          isExpanded: isDraftPanelExpanded,
          onToggleExpanded: onToggleDraftPanel,
          onAddTaskPressed: onAddTaskPressed,
          onTaskDeleted: onTaskDeleted,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: teamMembers.isEmpty
                ? (isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const GanttEmptyState())
                : errorMessage != null
                ? GanttErrorState(errorMessage: errorMessage, onRetry: onRetry)
                : isLoading
                ? const Center(child: CircularProgressIndicator())
                : GanttChartSurface(
                    selectedOrientation: selectedOrientation,
                    selectedPeriod: selectedPeriod,
                    teamMembers: teamMembers,
                    tasks: tasks,
                    startDate: startDate,
                    horizontalZoom: horizontalZoom,
                    onPointerSignal: onPointerSignal,
                    horizontalTimelineScrollController:
                        horizontalTimelineScrollController,
                    shouldScrollToToday: shouldScrollTimelineToToday,
                    onScrolledToToday: onTimelineScrolledToToday,
                    isToday: isToday,
                    calculateTaskLanes: calculateTaskLanes,
                    laneCount: laneCount,
                    onAppointmentDetails: onAppointmentDetails,
                    onEditTask: onEditTask,
                    onTaskDropped: onTaskDropped,
                    onTaskResized: onTaskResized,
                    isSameDate: isSameDate,
                    getViewDays: getViewDays,
                    toJulianDay: toJulianDay,
                    timeToFraction: timeToFraction,
                  ),
          ),
        ),
      ],
    );
  }
}

class GanttEmptyState extends StatelessWidget {
  const GanttEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'لا توجد مهام',
            style: AppTextStyles.h5.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على مهام في الفترة المحددة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class GanttErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const GanttErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56, color: AppColors.statusDelayed),
          const SizedBox(height: 12),
          Text(
            errorMessage ?? 'حدث خطأ',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class GanttCompactInfoBar extends StatelessWidget {
  const GanttCompactInfoBar({
    super.key,
    required this.draftTasks,
    required this.overloadedMembers,
    required this.delayedProjects,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onAddTaskPressed,
    required this.onTaskDeleted,
  });

  final List<TaskEntity> draftTasks;
  final List<TeamMemberEntity> overloadedMembers;
  final List<String> delayedProjects;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onAddTaskPressed;
  final Future<void> Function(String taskId) onTaskDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpanded,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: draftTasks.isEmpty
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
                          color: draftTasks.isEmpty
                              ? AppColors.textMuted
                              : AppColors.statusOnHold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'معلقة: ${draftTasks.length}',
                          style: TextStyle(
                            color: draftTasks.isEmpty
                                ? AppColors.textMuted
                                : AppColors.statusOnHold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (overloadedMembers.isNotEmpty)
                    _CompactWarning(
                      icon: Icons.warning_amber,
                      text: 'مثقل: ${overloadedMembers.length}',
                      color: AppColors.statusDelayed,
                    ),
                  if (delayedProjects.isNotEmpty)
                    _CompactWarning(
                      icon: Icons.schedule,
                      text: 'متأخر: ${delayedProjects.length}',
                      color: AppColors.statusOnHold,
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onAddTaskPressed,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('إضافة مهمة'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 24, color: AppColors.divider),
                  const SizedBox(width: 8),
                  ..._legendItems(),
                ],
              ),
            ),
          ),
          if (isExpanded && draftTasks.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'اسحب المهمة إلى الموظف لتعيينها',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: draftTasks
                          .map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: GanttDraftTaskChip(
                                task: task,
                                onDelete: () => _confirmDelete(context, task),
                              ),
                            ),
                          )
                          .toList(),
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

  List<Widget> _legendItems() {
    final items = [
      (TaskStatus.inProgress, 'جاري'),
      (TaskStatus.completed, 'مكتمل'),
      (TaskStatus.waiting, 'انتظار'),
      (TaskStatus.delayed, 'متأخر'),
    ];
    return items
        .map(
          (item) => Padding(
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
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  void _confirmDelete(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('حذف المهمة'),
        content: const Text('هل أنت متأكد من حذف هذه المهمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await onTaskDeleted(task.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDelayed,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _CompactWarning extends StatelessWidget {
  const _CompactWarning({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
