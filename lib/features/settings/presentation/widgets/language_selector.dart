import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/locale_provider.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          LanguageOption(
            title: 'العربية',
            subtitle: 'Arabic',
            badge: 'ع',
            isSelected: isArabic,
            onTap: () => localeProvider.setLocale(const Locale('ar')),
          ),
          Divider(color: AppColors.of(context).divider, height: 1),
          LanguageOption(
            title: 'English',
            subtitle: 'الإنجليزية',
            badge: 'En',
            isSelected: !isArabic,
            onTap: () => localeProvider.setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: isSelected
            ? AppColors.of(context).primary.withValues(alpha: 0.06)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.of(context).primary.withValues(alpha: 0.14)
                        : AppColors.of(context).surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.of(
                              context,
                            ).primary.withValues(alpha: 0.24)
                          : AppColors.of(context).border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ArabicNumberTransformer.transform(badge),
                      style: AppTextStyles.of(context).tableCellBold.copyWith(
                        color: isSelected
                            ? AppColors.of(context).primary
                            : AppColors.of(context).textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ArabicNumberTransformer.transform(title),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.of(context).tableCellBold.copyWith(
                          color: isSelected
                              ? AppColors.of(context).primary
                              : AppColors.of(context).textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSelected
                      ? Container(
                          key: const ValueKey('selected'),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 15,
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('not-selected'),
                          width: 25,
                          height: 25,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
