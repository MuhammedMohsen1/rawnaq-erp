import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ClipboardData, Clipboard;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';

import '../../domain/entities/project_entity.dart';

class ProjectContactActions extends StatelessWidget {
  final List<ProjectPhoneContact> contacts;
  final String? fallbackPhone;
  final String? fallbackName;
  final String? googleMapLink;
  final Function(String, String) onCopy;
  const ProjectContactActions({
    super.key,
    this.contacts = const [],
    this.fallbackPhone,
    this.fallbackName,
    this.googleMapLink,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final firstContact = _firstContact;
    final hasMap = (googleMapLink ?? '').trim().isNotEmpty;

    if (firstContact == null && !hasMap) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (firstContact != null)
          Tooltip(
            message: firstContact.name.trim().isEmpty
                ? firstContact.phone
                : '${firstContact.name} - ${firstContact.phone}',
            child: IconButton(
              onPressed: () => _launchPhone(context, firstContact.phone),
              iconSize: 16,
              onLongPress: () =>
                  onCopy(firstContact.phone, "تم نسخ أرقام الهاتف"),
              icon: const Icon(Icons.phone_android_rounded),
              color: AppColors.statusCompleted,
              style: _buttonStyle(AppColors.statusCompleted),
            ),
          ),
        if (hasMap) ...[
          if (firstContact != null) const SizedBox(width: 8),
          Tooltip(
            message: 'فتح الموقع على خرائط جوجل',
            child: IconButton(
              onPressed: () => _launchMap(context, googleMapLink!.trim()),
              icon: const Icon(Icons.map_outlined),
              color: AppColors.primary,
              style: _buttonStyle(AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }

  ProjectPhoneContact? get _firstContact {
    if (contacts.isNotEmpty) return contacts.first;
    final phone = fallbackPhone?.trim();
    if (phone == null || phone.isEmpty) return null;

    return ProjectPhoneContact(
      name: (fallbackName ?? '').trim().isEmpty ? 'رقم الهاتف' : fallbackName!,
      phone: phone,
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return IconButton.styleFrom(
      backgroundColor: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تعذر فتح تطبيق الهاتف')));
  }

  Future<void> _launchMap(BuildContext context, String link) async {
    final uri = _mapUri(link);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تعذر فتح رابط خرائط جوجل')));
  }

  Uri? _mapUri(String link) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) return null;

    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) return parsed;

    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': trimmed,
    });
  }
}

class ProjectContactActionsLoader extends StatelessWidget {
  final ProjectEntity project;

  const ProjectContactActionsLoader({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return ProjectContactActions(
      contacts: project.clientContacts,
      fallbackPhone: project.clientPhone,
      fallbackName: project.clientName,
      googleMapLink: project.googleMapLink,
      onCopy: (String phone, String message) {
        Clipboard.setData(ClipboardData(text: phone));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}
