import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../tasks/domain/entities/task_entity.dart';

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

class GanttCompactInfoBar extends StatefulWidget {
  final List<TaskEntity> draftTasks;
  final bool isDraftPanelExpanded;
  final VoidCallback onToggleDraftPanel;

  const GanttCompactInfoBar({
    super.key,
    required this.draftTasks,
    required this.isDraftPanelExpanded,
    required this.onToggleDraftPanel,
  });

  @override
  State<GanttCompactInfoBar> createState() => _GanttCompactInfoBarState();
}

class _GanttCompactInfoBarState extends State<GanttCompactInfoBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: widget.onToggleDraftPanel,
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
                  color: widget.draftTasks.isEmpty
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
                      color: widget.draftTasks.isEmpty
                          ? AppColors.textMuted
                          : AppColors.statusOnHold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'معلقة: ${widget.draftTasks.length}',
                      style: TextStyle(
                        color: widget.draftTasks.isEmpty
                            ? AppColors.textMuted
                            : AppColors.statusOnHold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      widget.isDraftPanelExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
