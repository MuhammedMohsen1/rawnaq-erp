import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../projects/domain/entities/team_member_entity.dart';

/// Time period options for Gantt chart
enum GanttTimePeriod {
  today,
  week,
  month,
  threeMonths,
}

extension GanttTimePeriodExtension on GanttTimePeriod {
  String get arabicName {
    switch (this) {
      case GanttTimePeriod.today:
        return 'اليوم';
      case GanttTimePeriod.week:
        return 'الأسبوع';
      case GanttTimePeriod.month:
        return 'الشهر';
      case GanttTimePeriod.threeMonths:
        return '3 شهور';
    }
  }
}

/// Widget for Gantt chart filters
class GanttFiltersWidget extends StatelessWidget {
  final GanttTimePeriod selectedPeriod;
  final bool showTeamTasks;
  final String? selectedMemberId;
  final List<TeamMemberEntity> teamMembers;
  final ValueChanged<GanttTimePeriod> onPeriodChanged;
  final ValueChanged<bool> onTeamTasksChanged;
  final ValueChanged<String?> onMemberChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onClearFilters;

  const GanttFiltersWidget({
    super.key,
    required this.selectedPeriod,
    required this.showTeamTasks,
    required this.selectedMemberId,
    required this.teamMembers,
    required this.onPeriodChanged,
    required this.onTeamTasksChanged,
    required this.onMemberChanged,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Time period tabs
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: GanttTimePeriod.values.map((period) {
                    final isSelected = selectedPeriod == period;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildPeriodChip(period, isSelected),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Second row: Team/My tasks toggle and member filter
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: [
            // My tasks / Team tasks toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton(
                    label: 'مهامي فقط',
                    icon: Icons.person_outline,
                    isSelected: !showTeamTasks,
                    onTap: () => onTeamTasksChanged(false),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: AppColors.border,
                  ),
                  _buildToggleButton(
                    label: 'مهام الفريق',
                    icon: Icons.group_outlined,
                    isSelected: showTeamTasks,
                    onTap: () => onTeamTasksChanged(true),
                  ),
                ],
              ),
            ),
            
            // Member dropdown
            if (showTeamTasks)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: selectedMemberId,
                    hint: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('الموظف:', style: AppTextStyles.inputHint),
                        const SizedBox(width: 8),
                        Text('الكل', style: AppTextStyles.inputText),
                      ],
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textMuted),
                    dropdownColor: AppColors.cardBackground,
                    style: AppTextStyles.inputText,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('الكل'),
                      ),
                      ...teamMembers.map((member) => DropdownMenuItem(
                            value: member.id,
                            child: Text(member.name),
                          )),
                    ],
                    onChanged: onMemberChanged,
                  ),
                ),
              ),
            
            // Apply / Clear buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: onApplyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.scaffoldBackground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('تطبيق الفلاتر'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onClearFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('مسح الفلاتر'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodChip(GanttTimePeriod period, bool isSelected) {
    return InkWell(
      onTap: () => onPeriodChanged(period),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          period.arabicName,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

