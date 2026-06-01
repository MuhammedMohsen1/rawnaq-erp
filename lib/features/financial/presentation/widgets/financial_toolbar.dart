import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class FinancialToolbar extends StatelessWidget {
  final int projectCount;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;

  const FinancialToolbar({
    super.key,
    required this.projectCount,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = SizedBox(
          width: constraints.maxWidth < 620 ? double.infinity : 340,
          child: TextField(
            onChanged: onSearchChanged,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: 'بحث بالمشروع أو العميل',
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.inputBackground,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.inputFocusBorder),
              ),
            ),
          ),
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$projectCount مشروع', style: AppTextStyles.label),
            const SizedBox(width: 12),
            Tooltip(
              message: 'تحديث',
              child: IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                color: AppColors.primary,
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [searchField, const SizedBox(height: 12), actions],
          );
        }

        return Row(children: [searchField, const Spacer(), actions]);
      },
    );
  }
}
