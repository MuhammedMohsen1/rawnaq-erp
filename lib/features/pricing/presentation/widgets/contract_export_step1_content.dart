import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ContractExportStep1Content extends StatelessWidget {
  final bool isLoadingProject;
  final String projectType;
  final TextEditingController civilIdController;
  final TextEditingController projectAddressController;
  final TextEditingController companySignerNameController;
  final TextEditingController designNotesController;
  final TextEditingController executionNotesController;
  final TextEditingController executionDurationDaysController;
  final List<Map<String, TextEditingController>> designScopeControllers;
  final VoidCallback onAddDesignScopeItem;
  final ValueChanged<int> onRemoveDesignScopeItem;

  const ContractExportStep1Content({
    super.key,
    required this.isLoadingProject,
    required this.projectType,
    required this.civilIdController,
    required this.projectAddressController,
    required this.companySignerNameController,
    required this.designNotesController,
    required this.executionNotesController,
    required this.executionDurationDaysController,
    required this.designScopeControllers,
    required this.onAddDesignScopeItem,
    required this.onRemoveDesignScopeItem,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingProject) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'أدخل الرقم المدني للعميل وعنوان المشروع',
                  style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: civilIdController,
          decoration: InputDecoration(
            labelText: 'الرقم المدني للعميل (12 رقم)',
            hintText: '298040400214',
            prefixIcon: const Icon(Icons.badge, color: AppColors.textSecondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 12,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: projectAddressController,
          decoration: InputDecoration(
            labelText: 'عنوان المشروع',
            hintText: 'مثال: قطعة 4 اليرموك - شارع 2 - جادة 2 - منزل 14',
            prefixIcon: const Icon(
              Icons.location_on,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.inputFocusBorder,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
          minLines: 3,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: companySignerNameController,
          decoration: InputDecoration(
            labelText: 'اسم ممثل الشركة بالتوقيع',
            hintText: 'مثال: محمود محسن',
            prefixIcon: const Icon(
              Icons.person,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.inputFocusBorder,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 20),
        if (projectType == 'DESIGN') ...[
          Row(
            children: [
              const Expanded(
                child: Text(
                  'المساحة المطلوب تصميمها',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: onAddDesignScopeItem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة مساحة'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...designScopeControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final scope = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('مساحة ${index + 1}'),
                      const Spacer(),
                      if (designScopeControllers.length > 1)
                        IconButton(
                          onPressed: () => onRemoveDesignScopeItem(index),
                          icon: const Icon(Icons.delete_outline),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: scope['item'],
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'البند',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: scope['description'],
                    minLines: 2,
                    maxLines: 4,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'التوصيف',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            );
          }),
          TextField(
            controller: designNotesController,
            minLines: 3,
            maxLines: 5,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'ملاحظات عقد التصميم',
              hintText: 'كل سطر سيضاف كملاحظة مستقلة',
              border: OutlineInputBorder(),
            ),
          ),
        ] else ...[
          TextField(
            controller: executionDurationDaysController,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: const InputDecoration(
              labelText: 'مدة التنفيذ بالأيام',
              hintText: '15',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: executionNotesController,
            minLines: 3,
            maxLines: 5,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'ملاحظات عقد التنفيذ',
              hintText: 'كل سطر سيضاف كملاحظة مستقلة',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}
