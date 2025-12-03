import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../tasks/domain/enums/task_status.dart';

/// Widget to display the status color legend
class StatusLegendWidget extends StatelessWidget {
  const StatusLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildLegendItem(TaskStatus.inProgress),
        const SizedBox(width: 16),
        _buildLegendItem(TaskStatus.completed),
        const SizedBox(width: 16),
        _buildLegendItem(TaskStatus.waiting),
        const SizedBox(width: 16),
        _buildLegendItem(TaskStatus.delayed),
      ],
    );
  }

  Widget _buildLegendItem(TaskStatus status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: status.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status.arabicName,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

