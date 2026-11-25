import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/enums/project_status.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

/// Widget for filtering projects
class ProjectFiltersWidget extends StatelessWidget {
  final ProjectStatus? selectedStatus;
  final String? selectedManagerId;
  final String? selectedTeamMemberId;
  final List<TeamMemberEntity> teamMembers;
  final ValueChanged<ProjectStatus?> onStatusChanged;
  final ValueChanged<String?> onManagerChanged;
  final ValueChanged<String?> onTeamMemberChanged;
  final VoidCallback onReset;

  const ProjectFiltersWidget({
    super.key,
    this.selectedStatus,
    this.selectedManagerId,
    this.selectedTeamMemberId,
    required this.teamMembers,
    required this.onStatusChanged,
    required this.onManagerChanged,
    required this.onTeamMemberChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    // Filter managers (those with role = مدير مشروع)
    final managers = teamMembers.where((m) => m.role.contains('مدير')).toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Status filter
        _buildDropdown<ProjectStatus?>(
          context,
          value: selectedStatus,
          hint: 'الحالة: الكل',
          icon: Icons.filter_list,
          items: [
            const DropdownMenuItem(value: null, child: Text('الحالة: الكل')),
            ...ProjectStatus.values.map(
              (status) => DropdownMenuItem(
                value: status,
                child: Text(
                  ArabicNumberTransformer.transform(status.arabicName),
                ),
              ),
            ),
          ],
          onChanged: onStatusChanged,
        ),

        // Manager filter
        _buildDropdown<String?>(
          context,
          value: selectedManagerId,
          hint: 'مدير المشروع',
          icon: Icons.person_outline,
          items: [
            const DropdownMenuItem(value: null, child: Text('مدير المشروع')),
            ...managers.map(
              (manager) => DropdownMenuItem(
                value: manager.id,
                child: Text(ArabicNumberTransformer.transform(manager.name)),
              ),
            ),
          ],
          onChanged: onManagerChanged,
        ),

        // Team member filter
        _buildDropdown<String?>(
          context,
          value: selectedTeamMemberId,
          hint: 'عضو الفريق',
          icon: Icons.group_outlined,
          items: [
            const DropdownMenuItem(value: null, child: Text('عضو الفريق')),
            ...teamMembers.map(
              (member) => DropdownMenuItem(
                value: member.id,
                child: Text(ArabicNumberTransformer.transform(member.name)),
              ),
            ),
          ],
          onChanged: onTeamMemberChanged,
        ),

        // Reset button
        TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('إعادة تعيين'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.of(context).textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context, {
    required T value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.of(context).textMuted),
              const SizedBox(width: 8),
              Text(
                ArabicNumberTransformer.transform(hint),
                style: AppTextStyles.of(context).inputHint,
              ),
            ],
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.of(context).textMuted,
          ),
          dropdownColor: AppColors.of(context).cardBackground,
          style: AppTextStyles.of(context).inputText,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
