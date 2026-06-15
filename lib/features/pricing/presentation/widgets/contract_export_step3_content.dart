import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ContractExportStep3Content extends StatelessWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> paymentPhases;
  final List<Map<String, TextEditingController>> paymentControllers;
  final VoidCallback onAddPaymentPhase;
  final ValueChanged<int> onRemovePaymentPhase;
  final void Function(int, String) onPhaseNameChanged;
  final void Function(int, double) onPercentageChanged;
  final void Function(int, double) onAmountChanged;

  const ContractExportStep3Content({
    super.key,
    required this.totalAmount,
    required this.paymentPhases,
    required this.paymentControllers,
    required this.onAddPaymentPhase,
    required this.onRemovePaymentPhase,
    required this.onPhaseNameChanged,
    required this.onPercentageChanged,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPercentage = paymentPhases.fold<double>(
      0.0,
      (sum, phase) => sum + (phase['percentage'] as num).toDouble(),
    );
    final totalAllocated = paymentPhases.fold<double>(
      0.0,
      (sum, phase) => sum + ((phase['amount'] as num?)?.toDouble() ?? 0.0),
    );
    final remainingAmount = totalAmount - totalAllocated;
    final remainingPercentage = 100.0 - totalPercentage;

    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي المبلغ: ${totalAmount.toStringAsFixed(3)} د.ك',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: onAddPaymentPhase,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('إضافة دفعة', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  (totalPercentage - 100.0).abs() < 0.01 &&
                      remainingAmount.abs() < 0.01
                  ? Colors.green[900]?.withValues(alpha: 0.2)
                  : Colors.orange[900]?.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    (totalPercentage - 100.0).abs() < 0.01 &&
                        remainingAmount.abs() < 0.01
                    ? Colors.green[300]!
                    : Colors.orange[300]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  (totalPercentage - 100.0).abs() < 0.01 &&
                          remainingAmount.abs() < 0.01
                      ? Icons.check_circle
                      : Icons.warning,
                  color:
                      (totalPercentage - 100.0).abs() < 0.01 &&
                          remainingAmount.abs() < 0.01
                      ? Colors.green[400]
                      : Colors.orange[400],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (totalPercentage - 100.0).abs() < 0.01 &&
                                remainingAmount.abs() < 0.01
                            ? 'المجموع: 100% ✓'
                            : 'المجموع: ${totalPercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color:
                              (totalPercentage - 100.0).abs() < 0.01 &&
                                  remainingAmount.abs() < 0.01
                              ? Colors.green[400]
                              : Colors.orange[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (remainingAmount.abs() > 0.01 ||
                          remainingPercentage.abs() > 0.01) ...[
                        const SizedBox(height: 4),
                        Text(
                          'المتبقي: ${remainingAmount.toStringAsFixed(3)} د.ك (${remainingPercentage.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            color: Colors.orange[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: paymentPhases.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'دفعة ${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (paymentPhases.length > 1)
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () => onRemovePaymentPhase(index),
                              tooltip: 'حذف الدفعة',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: paymentControllers[index]['phase'],
                        onChanged: (value) => onPhaseNameChanged(index, value),
                        decoration: InputDecoration(
                          labelText: 'اسم الدفعة',
                          hintText: 'مثال: دفعة أولى',
                          prefixIcon: const Icon(
                            Icons.payment,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.inputFocusBorder,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller:
                                  paymentControllers[index]['percentage'],
                              onChanged: (value) => onPercentageChanged(
                                index,
                                double.tryParse(value) ?? 0.0,
                              ),
                              decoration: InputDecoration(
                                labelText: 'النسبة %',
                                prefixIcon: const Icon(
                                  Icons.percent,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.inputBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.inputFocusBorder,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                isDense: true,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: paymentControllers[index]['amount'],
                              onChanged: (value) => onAmountChanged(
                                index,
                                double.tryParse(value) ?? 0.0,
                              ),
                              decoration: InputDecoration(
                                labelText: 'المبلغ',
                                suffixText: 'د.ك',
                                prefixIcon: const Icon(
                                  Icons.attach_money,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.inputBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.inputFocusBorder,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                isDense: true,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
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
