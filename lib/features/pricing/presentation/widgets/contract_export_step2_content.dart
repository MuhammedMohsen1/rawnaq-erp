import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ContractExportStep2Content extends StatelessWidget {
  final bool isLoadingTerms;
  final List<Map<String, TextEditingController>> contractTerms;
  final List<bool> termsApproved;
  final VoidCallback onApproveAll;
  final ValueChanged<int> onToggleApproved;

  const ContractExportStep2Content({
    super.key,
    required this.isLoadingTerms,
    required this.contractTerms,
    required this.termsApproved,
    required this.onApproveAll,
    required this.onToggleApproved,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingTerms) return const Center(child: CircularProgressIndicator());
    if (contractTerms.isEmpty) {
      return const Center(child: Text('لا توجد بنود عقد متاحة'));
    }

    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'يمكنك تعديل بنود العقد ثم الموافقة عليها:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: onApproveAll,
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('الموافقة على الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: contractTerms.length,
              itemBuilder: (context, index) {
                final term = contractTerms[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: termsApproved[index]
                        ? Colors.green[900]?.withValues(alpha: 0.2)
                        : AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: termsApproved[index]
                          ? Colors.green[300]!
                          : AppColors.border,
                      width: termsApproved[index] ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: termsApproved[index],
                            onChanged: (_) => onToggleApproved(index),
                            activeColor: Colors.green,
                          ),
                          Expanded(
                            child: Text(
                              'بند ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: term['title'],
                        decoration: InputDecoration(
                          labelText: 'العنوان',
                          hintText: 'مثال: أولا: التمهيد',
                          prefixIcon: const Icon(
                            Icons.title,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: term['description'],
                        maxLines: 6,
                        minLines: 4,
                        decoration: InputDecoration(
                          labelText: 'الوصف',
                          hintText: 'أدخل نص البند هنا...',
                          prefixIcon: const Icon(
                            Icons.description,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
