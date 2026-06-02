import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../projects/domain/entities/team_member_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/enums/task_status.dart';
import '../../../tasks/domain/enums/task_type.dart';
import '../widgets/appointment_widgets.dart';

class GanttDraftTaskChip extends StatelessWidget {
  const GanttDraftTaskChip({super.key, required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return Draggable<TaskEntity>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: _DraftTaskChipContent(task: task, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _DraftTaskChipContent(task: task),
      ),
      child: _DraftTaskChipContent(task: task),
    );
  }
}

class _DraftTaskChipContent extends StatelessWidget {
  const _DraftTaskChipContent({required this.task, this.isDragging = false});

  final TaskEntity task;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
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
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(task.taskType.icon, size: 14, color: task.taskType.color),
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
                style: TextStyle(fontSize: 10, color: AppColors.primary),
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
}

class GanttVerticalResizableTaskChip extends StatefulWidget {
  final TaskEntity task;
  final Color color;
  final String? compactMeta;
  final double rowHeight;
  final bool canResizeStart;
  final bool canResizeEnd;
  final void Function(TaskEntity task, DateTime newStart, DateTime newEnd)
  onResized;

  const GanttVerticalResizableTaskChip({
    required this.task,
    required this.color,
    required this.rowHeight,
    required this.canResizeStart,
    required this.canResizeEnd,
    required this.onResized,
    this.compactMeta,
    super.key,
  });

  @override
  State<GanttVerticalResizableTaskChip> createState() =>
      _GanttVerticalResizableTaskChipState();
}

class _GanttVerticalResizableTaskChipState
    extends State<GanttVerticalResizableTaskChip> {
  bool _isHovering = false;
  bool _isResizingStart = false;
  bool _isResizingEnd = false;
  double _dragDelta = 0;
  static const double _handleHeight = 7;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              constraints: const BoxConstraints(minHeight: 34),
              padding: EdgeInsets.fromLTRB(
                9,
                widget.canResizeStart ? 10 : 7,
                9,
                widget.canResizeEnd ? 10 : 7,
              ),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: widget.color.withValues(alpha: 0.95)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.task.taskType.icon,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.compactMeta != null &&
                            widget.compactMeta!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.compactMeta!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.canResizeStart)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHandle(isStart: true),
            ),
          if (widget.canResizeEnd)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildHandle(isStart: false),
            ),
        ],
      ),
    );
  }

  Widget _buildHandle({required bool isStart}) {
    final isActive = isStart ? _isResizingStart : _isResizingEnd;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (_) {
        setState(() {
          _dragDelta = 0;
          _isResizingStart = isStart;
          _isResizingEnd = !isStart;
        });
      },
      onVerticalDragUpdate: (details) =>
          setState(() => _dragDelta += details.delta.dy),
      onVerticalDragEnd: (_) {
        _applyResize(isStart);
        setState(() {
          _dragDelta = 0;
          _isResizingStart = false;
          _isResizingEnd = false;
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: _handleHeight,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: (_isHovering || isActive)
                ? Colors.white.withValues(alpha: 0.34)
                : Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: isStart ? const Radius.circular(6) : Radius.zero,
              bottom: isStart ? Radius.zero : const Radius.circular(6),
            ),
          ),
          child: (_isHovering || isActive)
              ? Center(
                  child: Container(
                    width: 22,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
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
    final dayDelta = (_dragDelta / widget.rowHeight).round();
    if (dayDelta == 0) return;
    final task = widget.task;
    DateTime newStart = task.startDate;
    DateTime newEnd = task.endDate;
    if (isStart) {
      newStart = DateTime(
        task.startDate.year,
        task.startDate.month,
        task.startDate.day + dayDelta,
        task.startDate.hour,
        task.startDate.minute,
        task.startDate.second,
      );
    } else {
      newEnd = DateTime(
        task.endDate.year,
        task.endDate.month,
        task.endDate.day + dayDelta,
        task.endDate.hour,
        task.endDate.minute,
        task.endDate.second,
      );
    }
    if (newStart.isBefore(newEnd)) {
      widget.onResized(task, newStart, newEnd);
    }
  }
}

class GanttResizableTaskBar extends StatefulWidget {
  final TaskEntity task;
  final double width;
  final double maxWidth;
  final double dayWidth;
  final VoidCallback? onDoubleTap;
  final void Function(DateTime newStart, DateTime newEnd)? onResized;

  const GanttResizableTaskBar({
    required this.task,
    required this.width,
    required this.maxWidth,
    required this.dayWidth,
    this.onDoubleTap,
    this.onResized,
    super.key,
  });

  @override
  State<GanttResizableTaskBar> createState() => _GanttResizableTaskBarState();
}

class GanttBarsForEmployee extends StatelessWidget {
  const GanttBarsForEmployee({
    super.key,
    required this.member,
    required this.tasks,
    required this.startDate,
    required this.displayDays,
    required this.taskLanes,
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
  final int displayDays;
  final Map<String, int> taskLanes;
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
      startDate.year,
      startDate.month,
      startDate.day + displayDays,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final dayWidth = constraints.maxWidth / displayDays;
        return Stack(
          children: [
            Row(
              children: List.generate(displayDays, (i) {
                final columnDate = DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day + i,
                );
                final today =
                    columnDate.year == DateTime.now().year &&
                    columnDate.month == DateTime.now().month &&
                    columnDate.day == DateTime.now().day;
                final weekend = columnDate.weekday == DateTime.friday;
                return Expanded(
                  child: DragTarget<TaskEntity>(
                    onWillAcceptWithDetails: (_) => true,
                    onAcceptWithDetails: (details) =>
                        onTaskDropped(details.data, member.id, columnDate),
                    builder: (context, candidateData, rejectedData) {
                      final hovering = candidateData.isNotEmpty;
                      return Container(
                        decoration: BoxDecoration(
                          color: hovering
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : (today
                                    ? AppColors.primary.withValues(alpha: 0.05)
                                    : (weekend
                                          ? AppColors.surfaceColor.withValues(
                                              alpha: 0.2,
                                            )
                                          : null)),
                          border: const Border(
                            left: BorderSide(color: AppColors.border, width: 1),
                          ),
                        ),
                        child: hovering
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
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
            ...tasks.map((task) {
              final taskStartJulian = toJulianDay(
                task.startDate.year,
                task.startDate.month,
                task.startDate.day,
              );
              final taskEndJulian = toJulianDay(
                task.endDate.year,
                task.endDate.month,
                task.endDate.day,
              );
              final chartStartJulian = toJulianDay(
                startDate.year,
                startDate.month,
                startDate.day,
              );
              final chartEndJulian = toJulianDay(
                endDate.year,
                endDate.month,
                endDate.day,
              );
              if (taskEndJulian < chartStartJulian ||
                  taskStartJulian > chartEndJulian) {
                return const SizedBox.shrink();
              }
              final startTimeFraction = timeToFraction(task.startDate);
              final endTimeFraction = timeToFraction(task.endDate);
              final visibleStartJulian = taskStartJulian < chartStartJulian
                  ? chartStartJulian
                  : taskStartJulian;
              final visibleEndJulian = taskEndJulian > chartEndJulian
                  ? chartEndJulian
                  : taskEndJulian;
              final visibleStartTimeFraction =
                  taskStartJulian < chartStartJulian ? 0.0 : startTimeFraction;
              final visibleEndTimeFraction = taskEndJulian > chartEndJulian
                  ? 1.0
                  : endTimeFraction;
              final startOffset =
                  (visibleStartJulian - chartStartJulian) +
                  visibleStartTimeFraction;
              final duration =
                  ((visibleEndJulian - visibleStartJulian) +
                          (visibleEndTimeFraction - visibleStartTimeFraction))
                      .clamp(0.1, 9999.0);
              if (task.isAppointment) {
                return Positioned(
                  right: startOffset * dayWidth,
                  top: 20 + ((taskLanes[task.id] ?? 0) * 38.0),
                  child: AppointmentCircle(
                    task: task,
                    onTap: () => onAppointmentDetails(task),
                    onDoubleTap: () => onEditTask(task),
                  ),
                );
              }
              final barRight = startOffset * dayWidth;
              final barWidth = duration * dayWidth;
              return Positioned(
                right: barRight,
                top: 20 + ((taskLanes[task.id] ?? 0) * 38.0),
                child: GanttResizableTaskBar(
                  task: task,
                  width: barWidth,
                  maxWidth: constraints.maxWidth - barRight,
                  dayWidth: dayWidth,
                  onDoubleTap: () => onEditTask(task),
                  onResized: (newStart, newEnd) =>
                      onTaskResized(task, newStart, newEnd),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _GanttResizableTaskBarState extends State<GanttResizableTaskBar> {
  bool _isHovering = false;
  bool _isResizingStart = false;
  bool _isResizingEnd = false;
  double _resizeDelta = 0;
  double _positionOffset = 0;
  static const double _handleWidth = 8.0;
  static const double _minBarWidth = 20.0;

  Color get _color => widget.task.taskType == TaskType.generalTask
      ? TaskType.generalTask.color
      : widget.task.status.color;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = (widget.width + _resizeDelta).clamp(
      _minBarWidth,
      widget.maxWidth,
    );
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
                Positioned.fill(
                  left: _handleWidth,
                  right: _handleWidth,
                  child: Draggable<TaskEntity>(
                    data: widget.task,
                    feedback: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(6),
                      child: _buildBarContent(
                        effectiveWidth - _handleWidth * 2,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.4,
                      child: _buildBarContent(
                        effectiveWidth - _handleWidth * 2,
                      ),
                    ),
                    child: Tooltip(
                      message: 'اسحب لنقل • انقر مرتين للتعديل',
                      child: _buildBarContent(
                        effectiveWidth - _handleWidth * 2,
                      ),
                    ),
                  ),
                ),
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
                Positioned.fill(
                  child: IgnorePointer(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final showIcon = constraints.maxWidth >= 54;
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth >= 44 ? 10 : 4,
                          ),
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: [
                              if (showIcon) ...[
                                Icon(
                                  widget.task.taskType.icon,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                              ],
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
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildResizeHandle(
                    isStart: true,
                    isActive: _isResizingStart,
                  ),
                ),
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
          if (isStart) {
            _resizeDelta += details.delta.dx;
            _positionOffset += details.delta.dx;
          } else {
            _resizeDelta -= details.delta.dx;
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
    final hoursChanged = (_resizeDelta / widget.dayWidth) * 24;
    DateTime newStart = widget.task.startDate;
    DateTime newEnd = widget.task.endDate;
    if (isStart) {
      newStart = widget.task.startDate.subtract(
        Duration(minutes: (hoursChanged * 60).round()),
      );
    } else {
      newEnd = widget.task.endDate.add(
        Duration(minutes: (hoursChanged * 60).round()),
      );
    }
    if (newStart.isBefore(newEnd)) {
      widget.onResized!(newStart, newEnd);
    }
  }
}
