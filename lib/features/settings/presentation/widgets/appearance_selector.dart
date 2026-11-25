import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/appearance_provider.dart';
import '../../../../core/widgets/app_toast.dart';

class AppearanceSelector extends StatelessWidget {
  const AppearanceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceProvider>();
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final mode in ThemeMode.values)
          ChoiceChip(
            label: Text(switch (mode) {
              ThemeMode.system => arabic ? 'حسب النظام' : 'System',
              ThemeMode.light => arabic ? 'فاتح' : 'Light',
              ThemeMode.dark => arabic ? 'داكن' : 'Dark',
            }),
            selected: appearance.mode == mode,
            showCheckmark: true,
            checkmarkColor: Theme.of(context).colorScheme.primary,
            onSelected: (_) async {
              try {
                await appearance.setMode(mode);
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  AppToast.build(
                    tone: ToastTone.error,
                    content: Text(
                      arabic
                          ? 'تعذّر حفظ إعداد المظهر'
                          : 'Could not save appearance preference',
                    ),
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
