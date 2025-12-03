import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/enums/task_status.dart';
import '../../../tasks/domain/enums/task_type.dart';
import '../../../projects/domain/entities/team_member_entity.dart';

/// Dialog for editing task dates and times (opened on double-tap)
class EditTaskDialog extends StatefulWidget {
  final TaskEntity task;
  final List<TeamMemberEntity> teamMembers;
  final Function(TaskEntity updatedTask) onTaskUpdated;
  final VoidCallback? onTaskDeleted;

  const EditTaskDialog({
    super.key,
    required this.task,
    required this.teamMembers,
    required this.onTaskUpdated,
    this.onTaskDeleted,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late String? _assigneeId;
  late TaskStatus _status;

  @override
  void initState() {
    super.initState();
    _startDate = widget.task.startDateOnly;
    _startTime = widget.task.startTimeOfDay;
    _endDate = widget.task.endDateOnly;
    _endTime = widget.task.endTimeOfDay;
    _assigneeId = widget.task.assigneeId;
    _status = widget.task.status;
  }

  @override
  Widget build(BuildContext context) {
    final isAppointment = widget.task.taskType == TaskType.appointment;

    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task info (read-only)
                  _buildTaskInfo(),
                  const SizedBox(height: 20),

                  // Assignee dropdown
                  _buildAssigneeDropdown(),
                  const SizedBox(height: 16),

                  // Status dropdown
                  _buildStatusDropdown(),
                  const SizedBox(height: 20),

                  // Start Date & Time
                  Text(
                    isAppointment ? 'تاريخ ووقت الموعد' : 'تاريخ ووقت البداية',
                    style: AppTextStyles.inputLabel.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildDateField(
                          value: _startDate,
                          onTap: () => _selectDate(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildTimeField(
                          value: _startTime,
                          onTap: () => _selectTime(true),
                        ),
                      ),
                    ],
                  ),

                  // End Date & Time (only for non-appointments)
                  if (!isAppointment) ...[
                    const SizedBox(height: 16),
                    Text(
                      'تاريخ ووقت النهاية',
                      style: AppTextStyles.inputLabel.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildDateField(
                            value: _endDate,
                            onTap: () => _selectDate(false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildTimeField(
                            value: _endTime,
                            onTap: () => _selectTime(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.task.taskType.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.task.taskType.icon,
              color: widget.task.taskType.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعديل المهمة',
                  style: AppTextStyles.h6,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.task.taskType.arabicName,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task.name,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          if (widget.task.projectName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.folder_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  widget.task.projectName!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
          if (widget.task.customerName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  widget.task.customerName!,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssigneeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الموظف المسؤول', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _assigneeId,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              dropdownColor: AppColors.cardBackground,
              style: AppTextStyles.inputText,
              items: widget.teamMembers.map((member) {
                return DropdownMenuItem(
                  value: member.id,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          member.name.substring(0, 1),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(member.name, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _assigneeId = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الحالة', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TaskStatus>(
              value: _status,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              dropdownColor: AppColors.cardBackground,
              style: AppTextStyles.inputText,
              items: TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: status.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(status.arabicName, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required DateTime value,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('EEE, d MMM yyyy', 'ar');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                dateFormat.format(value),
                style: AppTextStyles.inputText.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required TimeOfDay value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _formatTime(value),
                style: AppTextStyles.inputText.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          if (widget.task.taskType == TaskType.appointment) {
            _endDate = date;
          } else if (date.isAfter(_endDate)) {
            _endDate = date;
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
          if (widget.task.taskType == TaskType.appointment) {
            _endTime = time;
          }
        } else {
          _endTime = time;
        }
      });
    }
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // Delete button (optional)
          if (widget.onTaskDeleted != null)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'حذف المهمة',
              style: IconButton.styleFrom(
                foregroundColor: AppColors.statusDelayed,
              ),
            ),
          const Spacer(),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('حفظ التغييرات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.scaffoldBackground,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('حذف المهمة'),
        content: const Text('هل أنت متأكد من حذف هذه المهمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close confirm dialog
              Navigator.pop(context); // Close edit dialog
              widget.onTaskDeleted?.call();
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

  void _saveChanges() {
    if (_assigneeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار الموظف المسؤول'),
          backgroundColor: AppColors.statusDelayed,
        ),
      );
      return;
    }

    final assignee = widget.teamMembers.firstWhere(
      (m) => m.id == _assigneeId,
      orElse: () => widget.teamMembers.first,
    );

    // Combine date and time into DateTime
    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    DateTime endDateTime;
    if (widget.task.taskType == TaskType.appointment) {
      endDateTime = startDateTime;
    } else {
      endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );
    }

    final updatedTask = widget.task.copyWith(
      startDate: startDateTime,
      endDate: endDateTime,
      assigneeId: _assigneeId,
      assignee: assignee,
      status: _status,
      isDraft: false,
    );

    widget.onTaskUpdated(updatedTask);
    Navigator.pop(context);
  }
}
