import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class PricingSummarySidebar extends StatelessWidget {
  final double grandTotal;
  final String? lastSaveTime;
  final VoidCallback? onSubmit;
  final VoidCallback? onSaveDraft;

  const PricingSummarySidebar({
    super.key,
    required this.grandTotal,
    this.lastSaveTime,
    this.onSubmit,
    this.onSaveDraft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF1C212B),
        border: Border.all(color: const Color(0xFF363C4A)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 69,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C212B), Color(0xFF232936)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate,
                  color: Color(0xFF135BEC),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'ملخص التسعير',
                  style: AppTextStyles.h4.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grand Total Estimate Label
                Text(
                  'التقدير الإجمالي',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                // Grand Total Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      grandTotal.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.75,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'KD',
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Note
                Text(
                  'محسوب بناءً على الإدخالات الحالية. قد يختلف السعر النهائي بعد المراجعة.',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 16),
                // Last Save Time
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  decoration: const BoxDecoration(
                    color: Color(0xFF15181E),
                    border: Border(
                      top: BorderSide(color: Color(0xFF363C4A)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      lastSaveTime != null ? 'آخر حفظ: $lastSaveTime' : 'آخر حفظ: الآن',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF135BEC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      shadowColor: const Color(0xFF1E3A8A).withOpacity(0.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.send,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'إرسال التسعير للمراجعة',
                          style: AppTextStyles.buttonLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Save Draft Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: onSaveDraft,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD1D5DB),
                      side: const BorderSide(color: Color(0xFF363C4A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.save_outlined,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'حفظ كمسودة',
                          style: AppTextStyles.buttonLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD1D5DB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Tip Section
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF60A5FA),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'نصيحة: راجع جميع الإدخالات قبل الإرسال. يمكنك الحفظ كمسودة والمتابعة لاحقاً.',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFBFDBFE).withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

