import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/enums/project_status.dart';

class ProjectListSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ProjectListSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'ابحث باسم المشروع أو العميل',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'مسح البحث',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class ProjectListStatusFilterBar extends StatelessWidget {
  final ProjectStatus? selectedStatus;
  final int totalCount;
  final Map<ProjectStatus, int> counts;
  final List<ProjectStatus> availableStatuses;
  final ValueChanged<ProjectStatus?> onSelected;
  final VoidCallback? onCreateTap;

  const ProjectListStatusFilterBar({
    super.key,
    required this.selectedStatus,
    required this.totalCount,
    required this.counts,
    required this.availableStatuses,
    required this.onSelected,
    this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: 1 + availableStatuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                if (index == 0) {
                  return _StatusFilterChip(
                    label: 'الكل',
                    count: totalCount,
                    icon: Icons.grid_view_rounded,
                    accent: AppColors.primary,
                    selected: selectedStatus == null,
                    onTap: () => onSelected(null),
                  );
                }

                final status = availableStatuses[index - 1];
                final meta = _statusMetaOf(status);
                return _StatusFilterChip(
                  label: meta.label,
                  count: counts[status] ?? 0,
                  icon: meta.icon,
                  accent: meta.accent,
                  selected: selectedStatus == status,
                  onTap: () => onSelected(status),
                );
              },
            ),
          ),
          if (onCreateTap != null) ...[
            const SizedBox(width: 12),
            _PrimaryGlowButton(
              label: 'مشروع جديد',
              icon: Icons.add_rounded,
              onTap: onCreateTap!,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(0.12)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accent.withOpacity(0.40) : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? accent : AppColors.textMuted,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: selected ? accent : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              _CountBubble(count: count, color: accent, active: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBubble extends StatelessWidget {
  final int count;
  final Color color;
  final bool active;

  const _CountBubble({
    required this.count,
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.16) : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? color.withOpacity(0.25) : AppColors.border,
        ),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: active ? color : AppColors.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

class _PrimaryGlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryGlowButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
      ),
    );
  }
}

_StatusMeta _statusMetaOf(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.underPricing:
      return const _StatusMeta(
        label: 'التسعير والتوقيع',
        icon: Icons.calculate_rounded,
        accent: AppColors.primary,
      );
    case ProjectStatus.pendingSignature:
      return const _StatusMeta(
        label: 'بانتظار التوقيع',
        icon: Icons.draw_rounded,
        accent: AppColors.statusOnHold,
      );
    case ProjectStatus.execution:
      return const _StatusMeta(
        label: 'قيد التنفيذ',
        icon: Icons.rocket_launch_rounded,
        accent: AppColors.secondary,
      );
    case ProjectStatus.completed:
      return const _StatusMeta(
        label: 'مكتمل',
        icon: Icons.verified_rounded,
        accent: AppColors.statusCompleted,
      );
    case ProjectStatus.draft:
      return const _StatusMeta(
        label: 'مسودة',
        icon: Icons.description_outlined,
        accent: AppColors.textMuted,
      );
    default:
      return const _StatusMeta(
        label: 'أخرى',
        icon: Icons.folder_rounded,
        accent: AppColors.textMuted,
      );
  }
}

class _StatusMeta {
  final String label;
  final IconData icon;
  final Color accent;

  const _StatusMeta({
    required this.label,
    required this.icon,
    required this.accent,
  });
}
