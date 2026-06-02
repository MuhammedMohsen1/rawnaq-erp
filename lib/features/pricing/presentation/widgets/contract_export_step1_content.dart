import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ContractExportStep1Content extends StatelessWidget {
  final bool isLoadingProject;
  final TextEditingController civilIdController;
  final TextEditingController projectAddressController;

  const ContractExportStep1Content({
    super.key,
    required this.isLoadingProject,
    required this.civilIdController,
    required this.projectAddressController,
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
      ],
    );
  }
}
