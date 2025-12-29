import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../tasks/domain/enums/task_type.dart';
import '../../../tasks/domain/enums/task_status.dart'
    show TaskStatus, TaskStatusExtension;
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../projects/domain/entities/team_member_entity.dart';

/// Dialog for adding a new task
class AddTaskDialog extends StatefulWidget {
  final List<TeamMemberEntity> teamMembers;
  final String? preselectedMemberId;
  final DateTime? preselectedDate;
  final Function(TaskEntity) onTaskAdded;
  final bool allowDraft;

  // Mock projects for dropdown
  static const List<Map<String, String>> mockProjects = [
    {'id': 'proj-1', 'name': 'فيلا العبدالله'},
    {'id': 'proj-2', 'name': 'برج التجارة'},
    {'id': 'proj-3', 'name': 'شقة جدة'},
    {'id': 'proj-4', 'name': 'مكتب شركة التقنية'},
    {'id': 'proj-5', 'name': 'فندق الملك'},
    {'id': 'proj-6', 'name': 'مجمع سكني الرياض'},
    {'id': 'proj-7', 'name': 'مستشفى الخليج'},
    {'id': 'proj-8', 'name': 'مركز تسوق النخيل'},
    {'id': 'proj-9', 'name': 'مدرسة الأمل'},
    {'id': 'proj-10', 'name': 'مبنى المكاتب الإداري'},
    {'id': 'proj-11', 'name': 'فيلا الشاطئ'},
    {'id': 'proj-12', 'name': 'عمارة سكنية الطائف'},
    {'id': 'proj-13', 'name': 'مصنع الإنتاج'},
    {'id': 'proj-14', 'name': 'ملعب كرة القدم'},
    {'id': 'proj-15', 'name': 'مستودع التخزين'},
  ];

  const AddTaskDialog({
    super.key,
    required this.teamMembers,
    this.preselectedMemberId,
    this.preselectedDate,
    required this.onTaskAdded,
    this.allowDraft = false,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedMemberId;
  DateTime? _startDate;
  DateTime? _endDate;
  TaskStatus _status = TaskStatus.waiting;
  bool _saveAsDraft = false;

  // Work task fields
  String? _selectedProjectId;
  String? _selectedProjectName;

  // Time field (for work tasks and appointments)
  TimeOfDay? _taskTime;

  // Appointment fields
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _locationLinkController = TextEditingController();

  TaskType get _currentTaskType {
    switch (_tabController.index) {
      case 0:
        return TaskType.workTask;
      case 1:
        return TaskType.appointment;
      case 2:
        return TaskType.generalTask;
      default:
        return TaskType.workTask;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _selectedMemberId = widget.preselectedMemberId;
    _startDate = widget.preselectedDate ?? DateTime.now();
    _endDate = widget.preselectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _locationLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Task type tabs
            _buildTaskTypeTabs(),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Common fields
                      _buildTaskNameField(),
                      const SizedBox(height: 16),
                      _buildAssigneeDropdown(),
                      const SizedBox(height: 16),

                      // Type-specific fields
                      if (_currentTaskType == TaskType.workTask) ...[
                        _buildProjectDropdown(),
                        _buildTimePickerField(
                          label: 'وقت المهمة',
                          required: false,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_currentTaskType == TaskType.appointment)
                        _buildAppointmentFields(),

                      const SizedBox(height: 16),
                      _buildDateFields(),
                      const SizedBox(height: 16),
                      _buildStatusDropdown(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add_task, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إضافة مهمة جديدة', style: AppTextStyles.h5),
                const SizedBox(height: 4),
                Text(
                  'اختر نوع المهمة وأدخل البيانات المطلوبة',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypeTabs() {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surfaceColor),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(TaskType.workTask.icon, size: 18),
                const SizedBox(width: 8),
                const Text('مهمة مشروع'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(TaskType.appointment.icon, size: 18),
                const SizedBox(width: 8),
                const Text('موعد عميل'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(TaskType.generalTask.icon, size: 18),
                const SizedBox(width: 8),
                const Text('مهمة عامة'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskNameField() {
    String label;
    String hint;
    switch (_currentTaskType) {
      case TaskType.workTask:
        label = 'اسم المهمة';
        hint = 'أدخل اسم المهمة...';
        break;
      case TaskType.appointment:
        label = 'عنوان الموعد';
        hint = 'أدخل عنوان الموعد...';
        break;
      case TaskType.generalTask:
        label = 'اسم المهمة';
        hint = 'أدخل اسم المهمة...';
        break;
    }

    return _buildTextField(
      controller: _nameController,
      label: label,
      hint: hint,
      required: true,
    );
  }

  Widget _buildAssigneeDropdown() {
    final isRequired = !_saveAsDraft && !widget.allowDraft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الموظف المسؤول${isRequired ? ' *' : ''}',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        _buildDropdownContainer(
          child: DropdownButtonFormField<String>(
            value: _selectedMemberId,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
            ),
            dropdownColor: AppColors.cardBackground,
            style: AppTextStyles.inputText,
            hint: const Text('اختر الموظف', style: AppTextStyles.inputHint),
            items: widget.teamMembers.map(_buildMemberDropdownItem).toList(),
            onChanged: (value) => setState(() => _selectedMemberId = value),
            validator: (value) {
              if (_saveAsDraft) return null;
              return value == null ? 'يرجى اختيار الموظف المسؤول' : null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: child,
    );
  }

  DropdownMenuItem<String> _buildMemberDropdownItem(TeamMemberEntity member) {
    return DropdownMenuItem(
      value: member.id,
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              member.name.substring(0, 1),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(member.name),
        ],
      ),
    );
  }

  Widget _buildProjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المشروع *', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        _buildDropdownContainer(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedProjectId,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
            ),
            dropdownColor: AppColors.cardBackground,
            style: AppTextStyles.inputText,
            hint: const Text('اختر المشروع', style: AppTextStyles.inputHint),
            items: AddTaskDialog.mockProjects
                .map(_buildProjectDropdownItem)
                .toList(),
            onChanged: _handleProjectChange,
            validator: (value) =>
                _currentTaskType == TaskType.workTask && value == null
                ? 'يرجى اختيار المشروع'
                : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  DropdownMenuItem<String> _buildProjectDropdownItem(
    Map<String, String> project,
  ) {
    return DropdownMenuItem(
      value: project['id'],
      child: Text(project['name']!),
    );
  }

  void _handleProjectChange(String? value) {
    setState(() {
      _selectedProjectId = value;
      if (value != null) {
        _selectedProjectName = AddTaskDialog.mockProjects.firstWhere(
          (p) => p['id'] == value,
        )['name'];
      }
    });
  }

  Widget _buildAppointmentFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _customerNameController,
          label: 'اسم العميل',
          hint: 'أدخل اسم العميل...',
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _customerPhoneController,
          label: 'رقم الهاتف',
          hint: 'أدخل رقم الهاتف...',
          keyboardType: TextInputType.phone,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _locationLinkController,
          label: 'رابط الموقع (اختياري)',
          hint: 'رابط خرائط جوجل أو العنوان...',
        ),
        const SizedBox(height: 16),
        _buildTimePickerField(label: 'وقت الموعد', required: true),
      ],
    );
  }

  Widget _buildTimePickerField({required String label, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label${required ? ' *' : ''}', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        InkWell(
          onTap: _handleTimePicker,
          child: _buildInputContainer(
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _taskTime != null ? _formatTime(_taskTime!) : 'اختر الوقت',
                    style: _taskTime != null
                        ? AppTextStyles.inputText
                        : AppTextStyles.inputHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _taskTime ?? TimeOfDay.now(),
      builder: _buildPickerTheme,
    );
    if (time != null) {
      setState(() => _taskTime = time);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    return '$hour:$minute $period';
  }

  Widget _buildDateFields() {
    final isAppointment = _currentTaskType == TaskType.appointment;

    return Row(
      children: [
        Expanded(
          child: _buildDatePickerField(
            label: isAppointment ? 'تاريخ الموعد *' : 'تاريخ البداية *',
            value: _startDate,
            onTap: () => _selectDate(true),
          ),
        ),
        if (!isAppointment) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildDatePickerField(
              label: 'تاريخ النهاية *',
              value: _endDate,
              onTap: () => _selectDate(false),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: _buildInputContainer(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null ? dateFormat.format(value) : 'اختر التاريخ',
                    style: value != null
                        ? AppTextStyles.inputText
                        : AppTextStyles.inputHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: _buildPickerTheme,
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          // For appointments, end date is same as start date
          if (_currentTaskType == TaskType.appointment) {
            _endDate = date;
          } else if (_endDate != null && date.isAfter(_endDate!)) {
            _endDate = date;
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Widget _buildPickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.cardBackground,
        ),
      ),
      child: child!,
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: child,
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الحالة', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        _buildDropdownContainer(
          child: DropdownButtonFormField<TaskStatus>(
            value: _status,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
            ),
            dropdownColor: AppColors.cardBackground,
            style: AppTextStyles.inputText,
            items: TaskStatus.values.map(_buildStatusDropdownItem).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _status = value);
            },
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<TaskStatus> _buildStatusDropdownItem(TaskStatus status) {
    return DropdownMenuItem(
      value: status,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(status.arabicName),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return _buildTextField(
      controller: _notesController,
      label: 'ملاحظات',
      hint: 'أضف ملاحظات إضافية...',
      maxLines: 3,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label${required ? ' *' : ''}', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.inputHint,
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          validator: required
              ? (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Draft checkbox
          if (widget.allowDraft && _currentTaskType != TaskType.appointment)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Checkbox(
                    value: _saveAsDraft,
                    onChanged: (value) {
                      setState(() => _saveAsDraft = value ?? false);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.drafts_outlined,
                    size: 18,
                    color: _saveAsDraft
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'حفظ كمسودة (بدون تعيين موظف)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _saveAsDraft
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('إلغاء'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saveAsDraft
                      ? AppColors.statusOnHold
                      : AppColors.primary,
                  foregroundColor: AppColors.scaffoldBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(_saveAsDraft ? 'حفظ كمسودة' : 'إضافة المهمة'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateForm()) return;

    final task = _createTaskEntity();
    widget.onTaskAdded(task);
    Navigator.pop(context);
  }

  bool _validateForm() {
    if (!_saveAsDraft && _selectedMemberId == null) {
      _showError('يرجى اختيار الموظف المسؤول');
      return false;
    }
    if (_startDate == null) {
      _showError('يرجى اختيار تاريخ البداية');
      return false;
    }
    if (_currentTaskType != TaskType.appointment && _endDate == null) {
      _showError('يرجى اختيار تاريخ النهاية');
      return false;
    }
    if (_currentTaskType == TaskType.workTask && _selectedProjectId == null) {
      _showError('يرجى اختيار المشروع');
      return false;
    }
    if (_currentTaskType == TaskType.appointment) {
      if (_customerNameController.text.isEmpty) {
        _showError('يرجى إدخال اسم العميل');
        return false;
      }
      if (_customerPhoneController.text.isEmpty) {
        _showError('يرجى إدخال رقم الهاتف');
        return false;
      }
      if (_taskTime == null) {
        _showError('يرجى اختيار وقت الموعد');
        return false;
      }
    }
    return true;
  }

  TaskEntity _createTaskEntity() {
    TeamMemberEntity? assignee;
    if (_selectedMemberId != null) {
      assignee = widget.teamMembers.firstWhere(
        (m) => m.id == _selectedMemberId,
        orElse: () => widget.teamMembers.first,
      );
    }

    return TaskEntity(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      taskType: _currentTaskType,
      status: _saveAsDraft ? TaskStatus.waiting : _status,
      assigneeId: _saveAsDraft ? null : _selectedMemberId,
      assignee: _saveAsDraft ? null : assignee,
      isDraft: _saveAsDraft,
      startDate: _startDate!,
      endDate: _currentTaskType == TaskType.appointment
          ? _startDate!
          : _endDate!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      projectId: _currentTaskType == TaskType.workTask
          ? _selectedProjectId
          : null,
      projectName: _currentTaskType == TaskType.workTask
          ? _selectedProjectName
          : null,
      customerName: _currentTaskType == TaskType.appointment
          ? _customerNameController.text
          : null,
      customerPhone: _currentTaskType == TaskType.appointment
          ? _customerPhoneController.text
          : null,
      locationLink:
          _currentTaskType == TaskType.appointment &&
              _locationLinkController.text.isNotEmpty
          ? _locationLinkController.text
          : null,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.statusDelayed,
      ),
    );
  }
}
