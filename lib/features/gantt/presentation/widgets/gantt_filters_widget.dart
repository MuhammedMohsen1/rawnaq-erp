import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../projects/domain/entities/team_member_entity.dart';

/// Time period options for Gantt chart
enum GanttTimePeriod { today, week, month, threeMonths }

enum GanttLayoutOrientation { horizontal, vertical }

extension GanttLayoutOrientationExtension on GanttLayoutOrientation {
  String get arabicName {
    switch (this) {
      case GanttLayoutOrientation.horizontal:
        return 'أفقي';
      case GanttLayoutOrientation.vertical:
        return 'عمودي';
    }
  }
}

extension GanttTimePeriodExtension on GanttTimePeriod {
  String get arabicName {
    switch (this) {
      case GanttTimePeriod.today:
        return 'اليوم';
      case GanttTimePeriod.week:
        return 'أسبوع';
      case GanttTimePeriod.month:
        return 'شهر';
      case GanttTimePeriod.threeMonths:
        return '3 شهور';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttTimePeriod.today:
        return Icons.today;
      case GanttTimePeriod.week:
        return Icons.view_week;
      case GanttTimePeriod.month:
        return Icons.calendar_month;
      case GanttTimePeriod.threeMonths:
        return Icons.date_range;
    }
  }
}

/// Compact widget for Gantt chart filters - all in one row
class GanttFiltersWidget extends StatelessWidget {
  final GanttTimePeriod selectedPeriod;
  final GanttLayoutOrientation selectedOrientation;
  final bool showTeamTasks;
  final String? selectedMemberId;
  final List<TeamMemberEntity> teamMembers;
  final double zoomLevel;
  final ValueChanged<GanttTimePeriod> onPeriodChanged;
  final ValueChanged<GanttLayoutOrientation> onOrientationChanged;
  final ValueChanged<bool> onTeamTasksChanged;
  final ValueChanged<String?> onMemberChanged;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;
  final VoidCallback onApplyFilters;
  final VoidCallback onClearFilters;

  const GanttFiltersWidget({
    super.key,
    required this.selectedPeriod,
    required this.selectedOrientation,
    required this.showTeamTasks,
    required this.selectedMemberId,
    required this.teamMembers,
    required this.zoomLevel,
    required this.onPeriodChanged,
    required this.onOrientationChanged,
    required this.onTeamTasksChanged,
    required this.onMemberChanged,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Team/My toggle (compact)
        _buildTeamToggle(),

        const SizedBox(width: 12),

        _buildOrientationToggle(),

        const SizedBox(width: 12),

        // Member dropdown (compact)
        if (showTeamTasks) ...[
          _buildMemberDropdown(),
          const SizedBox(width: 12),
        ],

        const Spacer(),

        _buildZoomControls(),

        const SizedBox(width: 8),

        // Clear filters (icon only when filters applied)
        if (selectedMemberId != null || !showTeamTasks)
          IconButton(
            onPressed: onClearFilters,
            icon: const Icon(Icons.filter_alt_off, size: 20),
            tooltip: 'مسح الفلاتر',
            style: IconButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
      ],
    );
  }

  Widget _buildZoomControls() {
    final zoomPercent = (zoomLevel * 100).round();
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove, size: 16),
            tooltip: 'تصغير',
            style: IconButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              minimumSize: const Size(34, 34),
              padding: EdgeInsets.zero,
            ),
          ),
          InkWell(
            onTap: onResetZoom,
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 52,
              child: Text(
                '$zoomPercent%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onZoomIn,
            icon: const Icon(Icons.add, size: 16),
            tooltip: 'تكبير',
            style: IconButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              minimumSize: const Size(34, 34),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamToggle() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniToggle(
            icon: Icons.person,
            label: 'مهامي',
            isSelected: !showTeamTasks,
            onTap: () {
              onTeamTasksChanged(false);
              onApplyFilters();
            },
          ),
          _buildMiniToggle(
            icon: Icons.group,
            label: 'الفريق',
            isSelected: showTeamTasks,
            onTap: () {
              onTeamTasksChanged(true);
              onApplyFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrientationToggle() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: GanttLayoutOrientation.values.map((orientation) {
          final isSelected = selectedOrientation == orientation;
          return _buildMiniToggle(
            icon: orientation == GanttLayoutOrientation.horizontal
                ? Icons.swap_horiz
                : Icons.swap_vert,
            label: orientation.arabicName,
            isSelected: isSelected,
            onTap: () => onOrientationChanged(orientation),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMiniToggle({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberDropdown() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: selectedMemberId != null
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedMemberId,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_search, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'كل الموظفين',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: selectedMemberId != null
                ? AppColors.primary
                : AppColors.textMuted,
            size: 20,
          ),
          isDense: true,
          dropdownColor: AppColors.cardBackground,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
          items: [
            DropdownMenuItem(
              value: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  const Text('كل الموظفين'),
                ],
              ),
            ),
            ...teamMembers.map(
              (member) => DropdownMenuItem(
                value: member.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        member.name.substring(0, 1),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(member.name, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (value) {
            onMemberChanged(value);
            onApplyFilters();
          },
        ),
      ),
    );
  }
}
