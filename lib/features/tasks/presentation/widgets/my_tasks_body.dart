import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';
import 'my_task_card.dart';

class MyTasksBody extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<TaskEntity> tasks;
  final Future<void> Function() onRetry;
  final Future<void> Function(TaskEntity task, TaskStatus status)
  onTaskStatusChanged;

  const MyTasksBody({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.tasks,
    required this.onRetry,
    required this.onTaskStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppColors.statusDelayed),
            const SizedBox(height: 12),
            Text(errorMessage!, style: AppTextStyles.h5),
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

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'لا توجد مهام مسندة لك اليوم',
              style: AppTextStyles.h5.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => MyTaskCard(
        task: tasks[index],
        onStatusChanged: (status) => onTaskStatusChanged(tasks[index], status),
      ),
    );
  }
}
