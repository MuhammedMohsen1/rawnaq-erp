import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/dialog_keyboard_actions.dart';
import '../../domain/entities/project_entity.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/projects_event.dart';

/// Dialog for editing an existing project
class EditProjectDialog extends StatefulWidget {
  final ProjectEntity project;

  const EditProjectDialog({super.key, required this.project});

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _googleMapLinkController = TextEditingController();
  final List<TextEditingController> _contactNameControllers = [];
  final List<TextEditingController> _contactPhoneControllers = [];

  // End date
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing project data
    _nameController.text = widget.project.name;
    _descriptionController.text = widget.project.description ?? '';
    _clientNameController.text = widget.project.clientName ?? '';
    _googleMapLinkController.text = widget.project.googleMapLink ?? '';
    final contacts = widget.project.clientContacts.isNotEmpty
        ? widget.project.clientContacts
        : [
            if ((widget.project.clientPhone ?? '').trim().isNotEmpty)
              ProjectPhoneContact(
                name: widget.project.clientName ?? 'بدون اسم',
                phone: widget.project.clientPhone!,
              ),
          ];
    if (contacts.isEmpty) {
      _contactNameControllers.add(TextEditingController());
      _contactPhoneControllers.add(TextEditingController());
    } else {
      for (final contact in contacts) {
        _contactNameControllers.add(TextEditingController(text: contact.name));
        _contactPhoneControllers.add(
          TextEditingController(text: contact.phone),
        );
      }
    }
    _endDate = widget.project.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _clientNameController.dispose();
    _googleMapLinkController.dispose();
    for (final controller in _contactNameControllers) {
      controller.dispose();
    }
    for (final controller in _contactPhoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogKeyboardActions(
      onSubmit: _handleSave,
      onClose: () => Navigator.of(context).pop(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildForm(),
                ),
              ),

              // Footer with action buttons
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'تعديل المشروع',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات المشروع',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Project Name
          _buildTextField(
            controller: _nameController,
            label: 'اسم المشروع *',
            hint: 'أدخل اسم المشروع',
            icon: Icons.folder_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'اسم المشروع مطلوب';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          _buildTextField(
            controller: _descriptionController,
            label: 'الوصف',
            hint: 'أدخل وصف المشروع (اختياري)',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Client Information Section
          Text(
            'معلومات العميل',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _clientNameController,
            label: 'اسم العميل',
            hint: 'أدخل اسم العميل (اختياري)',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          _buildContactsFields(),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _googleMapLinkController,
            label: 'رابط خرائط جوجل',
            hint: 'رابط الموقع على خرائط جوجل (اختياري)',
            icon: Icons.map_outlined,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),

          // End Date Section
          Text(
            'تاريخ الانتهاء',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildDatePicker(
            label: 'تاريخ الانتهاء',
            date: _endDate,
            onDateSelected: (date) {
              setState(() {
                _endDate = date;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'أرقام الهاتف',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _contactNameControllers.add(TextEditingController());
                  _contactPhoneControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة رقم'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _contactPhoneControllers.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _contactNameControllers[i],
                  label: 'الاسم',
                  hint: 'مثال: العميل',
                  icon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _contactPhoneControllers[i],
                  label: 'رقم الهاتف',
                  hint: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
              if (_contactPhoneControllers.length > 1) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _contactNameControllers.removeAt(i).dispose();
                      _contactPhoneControllers.removeAt(i).dispose();
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                ),
              ],
            ],
          ),
          if (i < _contactPhoneControllers.length - 1)
            const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.inputFocusBorder,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primary,
                      onPrimary: AppColors.scaffoldBackground,
                      surface: AppColors.cardBackground,
                      onSurface: AppColors.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.year}/${date.month}/${date.day}'
                        : 'اختر التاريخ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: date != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.scaffoldBackground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'حفظ التغييرات',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final contacts = _collectContacts();

    // Create updated project entity
    final updatedProject = widget.project.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      clientName: _clientNameController.text.trim(),
      clientPhone: contacts.isEmpty ? '' : contacts.first.phone,
      clientContacts: contacts,
      googleMapLink: _googleMapLinkController.text.trim(),
      endDate: _endDate ?? widget.project.endDate,
    );

    // Dispatch update project event
    context.read<ProjectsBloc>().add(UpdateProject(updatedProject));

    // Close dialog
    Navigator.of(context).pop();
  }

  List<ProjectPhoneContact> _collectContacts() {
    final contacts = <ProjectPhoneContact>[];

    for (var i = 0; i < _contactPhoneControllers.length; i++) {
      final name = _contactNameControllers[i].text.trim();
      final phone = _contactPhoneControllers[i].text.trim();
      if (name.isEmpty && phone.isEmpty) continue;

      contacts.add(
        ProjectPhoneContact(
          name: name.isEmpty ? 'بدون اسم' : name,
          phone: phone,
        ),
      );
    }

    return contacts;
  }
}
