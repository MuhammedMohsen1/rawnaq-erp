import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/projects_event.dart';

/// Multi-step dialog for creating a new project
class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  int _currentStep = 0;
  
  // Project type selection
  String? _selectedProjectType; // 'DESIGN' or 'EXECUTION'
  
  // Form fields
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  
  // Department selection (for now, using mock data - should be fetched from API)
  String? _selectedDepartmentId;
  final List<Map<String, String>> _allDepartments = [
    {'id': 'dept-1', 'name': 'قسم التنفيذ', 'nameEn': 'Execution', 'type': 'EXECUTION'},
    {'id': 'dept-2', 'name': 'قسم التصميم الداخلي', 'nameEn': 'Interior Design', 'type': 'DESIGN'},
  ];
  
  // Get filtered departments based on project type
  List<Map<String, String>> get _departments {
    if (_selectedProjectType == null) return [];
    return _allDepartments
        .where((dept) => dept['type'] == _selectedProjectType)
        .toList();
  }
  
  // No date or progress fields needed - will be set by backend

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                child: _buildStepContent(),
              ),
            ),
            
            // Footer with navigation buttons
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add_circle_outline,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'إنشاء مشروع جديد',
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

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return _buildProjectTypeSelection();
    } else if (_currentStep == 1) {
      return _buildProjectDetailsForm();
    }
    return const SizedBox.shrink();
  }

  Widget _buildProjectTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر نوع المشروع',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختر نوع المشروع الذي تريد إنشاءه',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        
        // Design Project Option
        _buildProjectTypeCard(
          title: 'مشروع تصميم',
          subtitle: 'مشاريع التصميم الداخلي',
          icon: Icons.palette_outlined,
          type: 'DESIGN',
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 16),
        
        // Execution Project Option
        _buildProjectTypeCard(
          title: 'مشروع تنفيذ',
          subtitle: 'مشاريع التنفيذ والبناء',
          icon: Icons.build_outlined,
          type: 'EXECUTION',
          color: const Color(0xFF22C55E),
        ),
      ],
    );
  }

  Widget _buildProjectTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
    required Color color,
  }) {
    final isSelected = _selectedProjectType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedProjectType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDetailsForm() {
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
          
          // Department is auto-selected based on project type (read-only display)
          _buildDepartmentDisplay(),
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
          
          _buildTextField(
            controller: _clientPhoneController,
            label: 'رقم الهاتف',
            hint: 'رقم الهاتف (اختياري)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
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
              borderSide: BorderSide(color: AppColors.inputFocusBorder, width: 2),
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

  Widget _buildDepartmentDisplay() {
    final department = _departments.isNotEmpty ? _departments.first : null;
    final departmentName = department?['name'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'القسم',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.business_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  departmentName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (only show if not on first step)
          if (_currentStep > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              child: const Text('رجوع'),
            )
          else
            const SizedBox.shrink(),
          
          // Next/Submit button
          ElevatedButton(
            onPressed: _handleNextOrSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.scaffoldBackground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _currentStep == 0 ? 'التالي' : 'إنشاء المشروع',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextOrSubmit() {
    if (_currentStep == 0) {
      // Validate project type selection
      if (_selectedProjectType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار نوع المشروع'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      // Move to next step and auto-select the matching department
      setState(() {
        _currentStep = 1;
        // Auto-select the department that matches the project type
        final matchingDept = _departments.isNotEmpty ? _departments.first : null;
        if (matchingDept != null) {
          _selectedDepartmentId = matchingDept['id'];
        }
      });
    } else {
      // Validate and submit form
      if (!_formKey.currentState!.validate()) {
        return;
      }
      
      // Department is auto-selected, but verify it's set
      if (_selectedDepartmentId == null || _departments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في تحديد القسم'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      // Dispatch create project event with all data
      // Start date will be current date (created date)
      final now = DateTime.now();
      
      context.read<ProjectsBloc>().add(
        CreateProjectWithData(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          type: _selectedProjectType ?? 'EXECUTION',
          primaryDepartmentId: _selectedDepartmentId ?? '',
          clientName: _clientNameController.text.trim().isEmpty
              ? null
              : _clientNameController.text.trim(),
          clientPhone: _clientPhoneController.text.trim().isEmpty
              ? null
              : _clientPhoneController.text.trim(),
          clientEmail: null, // Email not needed
          startDate: now, // Start date is the created date
          endDate: null, // End date not required when creating
          deadline: null, // Deadline not needed
          progress: 0, // Progress starts at 0
        ),
      );
      
      // Close dialog
      Navigator.of(context).pop();
    }
  }
}

