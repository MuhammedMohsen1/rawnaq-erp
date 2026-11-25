import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                if (leadingIcon != null) ...[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.of(context).surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.of(context).border),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: AppColors.of(context).textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ArabicNumberTransformer.transform(title),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.of(context).tableCellBold,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ArabicNumberTransformer.transform(subtitle),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.of(context).caption.copyWith(
                          color: AppColors.of(context).textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 12), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
