import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../tasks/domain/enums/task_type.dart';
import '../../../tasks/domain/enums/task_status.dart' show TaskStatus;
import '../../../tasks/domain/entities/task_entity.dart';

/// Simple dialog for adding a new task (always as draft - no assignee)
class AddTaskDialogSimple extends StatefulWidget {
  final Function(TaskEntity) onTaskAdded;

  // Mock projects for dropdown
  static const List<Map<String, String>> mockProjects = [
    {'id': 'proj-1', 'name': 'فيلا العبدالله'},
    {'id': 'proj-2', 'name': 'برج التجارة'},
    {'id': 'proj-3', 'name': 'شقة جدة'},
    {'id': 'proj-4', 'name': 'مكتب شركة التقنية'},
    {'id': 'proj-5', 'name': 'فندق الملك'},
  ];

  const AddTaskDialogSimple({
    super.key,
    required this.onTaskAdded,
  });

  @override
  State<AddTaskDialogSimple> createState() => _AddTaskDialogSimpleState();
}

class _AddTaskDialogSimpleState extends State<AddTaskDialogSimple>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Date and time fields
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  // Work task fields
  String? _selectedProjectId;
  String? _selectedProjectName;

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
    _startDate = DateTime.now();
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endDate = DateTime.now();
    _endTime = const TimeOfDay(hour: 17, minute: 0);
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
        width: 520,
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildTaskTypeTabs(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaskNameField(),
                      const SizedBox(height: 16),

                      // Type-specific fields
                      if (_currentTaskType == TaskType.workTask) ...[
                        _buildProjectDropdown(),
                        const SizedBox(height: 16),
                      ],
                      if (_currentTaskType == TaskType.appointment)
                        _buildAppointmentFields(),

                      // Date and time fields
                      _buildDateTimeFields(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                    ],
                  ),
                ),
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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.statusOnHold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.add_task,
              color: AppColors.statusOnHold,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إضافة مهمة جديدة', style: AppTextStyles.h5),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ستُضاف للمهام المعلقة - اسحبها للتعيين',
                      style: AppTextStyles.caption,
                    ),
                  ],
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
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
      ),
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

  Widget _buildProjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المشروع *', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedProjectId,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
            ),
            dropdownColor: AppColors.cardBackground,
            style: AppTextStyles.inputText,
            hint: const Text('اختر المشروع', style: AppTextStyles.inputHint),
            items: AddTaskDialogSimple.mockProjects.map((project) {
              return DropdownMenuItem(
                value: project['id'],
                child: Text(project['name']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProjectId = value;
                _selectedProjectName = AddTaskDialogSimple.mockProjects
                    .firstWhere((p) => p['id'] == value)['name'];
              });
            },
            validator: (value) =>
                _currentTaskType == TaskType.workTask && value == null
                    ? 'يرجى اختيار المشروع'
                    : null,
          ),
        ),
      ],
    );
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
      ],
    );
  }

  Widget _buildDateTimeFields() {
    final isAppointment = _currentTaskType == TaskType.appointment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Start Date & Time
        Text(
          isAppointment ? 'تاريخ ووقت الموعد *' : 'تاريخ ووقت البداية *',
          style: AppTextStyles.inputLabel.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildDatePickerField(
                value: _startDate,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildTimePickerField(
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
            'تاريخ ووقت النهاية *',
            style: AppTextStyles.inputLabel.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildDatePickerField(
                  value: _endDate,
                  onTap: () => _selectDate(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildTimePickerField(
                  value: _endTime,
                  onTap: () => _selectTime(false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDatePickerField({
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('EEE, d MMM', 'ar');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                value != null ? dateFormat.format(value) : 'اختر التاريخ',
                style: value != null
                    ? AppTextStyles.inputText
                    : AppTextStyles.inputHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerField({
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                value != null ? _formatTime(value) : 'الوقت',
                style: value != null
                    ? AppTextStyles.inputText
                    : AppTextStyles.inputHint,
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
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
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

  Future<void> _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: (isStartTime ? _startTime : _endTime) ?? TimeOfDay.now(),
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
          if (_currentTaskType == TaskType.appointment) {
            _endTime = time;
          }
        } else {
          _endTime = time;
        }
      });
    }
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          validator: required
              ? (value) =>
                  value?.isEmpty == true ? 'هذا الحقل مطلوب' : null
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _submitForm,
            icon: const Icon(Icons.pending_actions, size: 18),
            label: const Text('إضافة للمعلقة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusOnHold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Validation
    if (_startDate == null || _startTime == null) {
      _showError('يرجى اختيار تاريخ ووقت البداية');
      return;
    }
    if (_currentTaskType != TaskType.appointment) {
      if (_endDate == null || _endTime == null) {
        _showError('يرجى اختيار تاريخ ووقت النهاية');
        return;
      }
    }
    if (_currentTaskType == TaskType.workTask && _selectedProjectId == null) {
      _showError('يرجى اختيار المشروع');
      return;
    }
    if (_currentTaskType == TaskType.appointment) {
      if (_customerNameController.text.isEmpty) {
        _showError('يرجى إدخال اسم العميل');
        return;
      }
      if (_customerPhoneController.text.isEmpty) {
        _showError('يرجى إدخال رقم الهاتف');
        return;
      }
    }

    // Combine date and time into DateTime
    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    DateTime endDateTime;
    if (_currentTaskType == TaskType.appointment) {
      // Appointments are single-point events
      endDateTime = startDateTime;
    } else {
      endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    // Create task as draft (no assignee)
    final task = TaskEntity(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      taskType: _currentTaskType,
      status: TaskStatus.waiting,
      assigneeId: null, // Always null - it's a draft
      assignee: null,
      isDraft: true, // Always true
      startDate: startDateTime,
      endDate: endDateTime,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      projectId: _currentTaskType == TaskType.workTask ? _selectedProjectId : null,
      projectName: _currentTaskType == TaskType.workTask ? _selectedProjectName : null,
      customerName: _currentTaskType == TaskType.appointment
          ? _customerNameController.text
          : null,
      customerPhone: _currentTaskType == TaskType.appointment
          ? _customerPhoneController.text
          : null,
      locationLink: _currentTaskType == TaskType.appointment &&
              _locationLinkController.text.isNotEmpty
          ? _locationLinkController.text
          : null,
    );

    widget.onTaskAdded(task);
    Navigator.pop(context);
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
