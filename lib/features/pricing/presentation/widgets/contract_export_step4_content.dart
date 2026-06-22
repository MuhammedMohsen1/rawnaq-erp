import 'package:flutter/material.dart';
import 'contract_export_review_item.dart';

class ContractExportStep4Content extends StatelessWidget {
  final bool isExporting;
  final String projectType;
  final TextEditingController civilIdController;
  final TextEditingController projectAddressController;
  final int contractTermsCount;
  final int paymentPhasesCount;
  final bool showExecutionItemPrices;
  final ValueChanged<bool> onShowExecutionItemPricesChanged;
  final int designScopeCount;
  final VoidCallback onExportPdf;

  const ContractExportStep4Content({
    super.key,
    required this.isExporting,
    required this.projectType,
    required this.civilIdController,
    required this.projectAddressController,
    required this.contractTermsCount,
    required this.paymentPhasesCount,
    required this.showExecutionItemPrices,
    required this.onShowExecutionItemPricesChanged,
    required this.designScopeCount,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    if (isExporting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تصدير PDF...'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مراجعة المعلومات قبل التصدير:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ContractExportReviewItem(
          label: 'نوع العقد',
          value: projectType == 'DESIGN' ? 'عقد تصميم' : 'عقد تنفيذ',
        ),
        ContractExportReviewItem(
          label: 'الرقم المدني',
          value: civilIdController.text,
        ),
        ContractExportReviewItem(
          label: 'عنوان المشروع',
          value: projectAddressController.text,
        ),
        ContractExportReviewItem(
          label: 'عدد البنود',
          value: '$contractTermsCount بند',
        ),
        if (projectType == 'DESIGN')
          ContractExportReviewItem(
            label: 'عدد عناصر المساحة',
            value: '$designScopeCount عنصر',
          ),
        ContractExportReviewItem(
          label: 'عدد الدفعات',
          value: '$paymentPhasesCount دفعة',
        ),
        if (projectType != 'DESIGN') ...[
          const SizedBox(height: 8),
          CheckboxListTile(
            value: showExecutionItemPrices,
            onChanged: (value) =>
                onShowExecutionItemPricesChanged(value ?? false),
            title: const Text('إظهار سعر كل بند'),
            subtitle: const Text('عند الإلغاء يظهر الإجمالي فقط في العقد'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('تصدير PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
