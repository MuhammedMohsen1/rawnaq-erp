import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/enums/task_type.dart';

class MyTaskCard extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<TaskStatus> onStatusChanged;

  const MyTaskCard({
    super.key,
    required this.task,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = task.taskType == TaskType.generalTask
        ? TaskType.generalTask.color
        : task.status.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 58,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Icon(task.taskType.icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: AppTextStyles.tableCellBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _TaskMeta(
                      icon: Icons.category_outlined,
                      text: task.taskType.arabicName,
                    ),
                    if (task.projectName != null)
                      _TaskMeta(
                        icon: Icons.folder_outlined,
                        text: task.projectName!,
                      ),
                    _TaskMeta(
                      icon: Icons.schedule,
                      text:
                          '${task.formattedStartTime} - ${task.formattedEndTime}',
                    ),
                    _TaskMeta(
                      icon: Icons.timelapse_outlined,
                      text: 'المدة: ${_formatDuration(task)}',
                    ),
                    _TaskMeta(
                      icon: Icons.event_available_outlined,
                      text: _formatRemainingDays(task),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _TaskStatusMenu(task: task, onSelected: onStatusChanged),
        ],
      ),
    );
  }

  String _formatDuration(TaskEntity task) {
    if (task.isAppointment) return 'موعد';
    final days = task.durationDays;
    if (days <= 1) return 'يوم واحد';
    if (days == 2) return 'يومان';
    return '$days أيام';
  }

  String _formatRemainingDays(TaskEntity task) {
    final days = task.remainingDays;
    if (task.status == TaskStatus.completed) return 'مكتملة';
    if (days < 0) return 'متأخرة ${days.abs()} يوم';
    if (days == 0) return 'تنتهي اليوم';
    if (days == 1) return 'متبقي يوم';
    if (days == 2) return 'متبقي يومان';
    return 'متبقي $days أيام';
  }
}

class _TaskMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TaskMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _TaskStatusMenu extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<TaskStatus> onSelected;

  const _TaskStatusMenu({required this.task, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskStatus>(
      tooltip: 'تحديث الحالة',
      color: AppColors.cardBackground,
      onSelected: onSelected,
      itemBuilder: (context) =>
          [TaskStatus.waiting, TaskStatus.inProgress, TaskStatus.completed].map(
            (status) {
              return PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: status.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(status.arabicName),
                  ],
                ),
              );
            },
          ).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: task.status.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: task.status.color.withValues(alpha: 0.3)),
        ),
        child: Text(
          task.status.arabicName,
          style: TextStyle(
            color: task.status.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
