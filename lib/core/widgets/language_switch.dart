import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          onSelected: (languageCode) {
            localeProvider.setLocale(Locale(languageCode));
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'ar',
              child: Row(
                children: [
                  Text('🇸🇦', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text('العربية'),
                  if (localeProvider.isArabic) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Colors.green),
                  ],
                ],
              ),
            ),
            PopupMenuItem(
              value: 'en',
              child: Row(
                children: [
                  Text('🇺🇸', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text('English'),
                  if (localeProvider.isEnglish) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Colors.green),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
