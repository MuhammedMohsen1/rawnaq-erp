import 'package:flutter/material.dart';

/// Collection of confirmation dialogs for pricing actions
class PricingConfirmationDialogs {
  /// Show return to pricing confirmation dialog
  static Future<(bool, String?)> showReturnToPricingDialog(
    BuildContext context,
  ) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إرجاع التسعير للتعديل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'هل أنت متأكد من إرجاع التسعير إلى حالة التعديل؟ سيتم إلغاء عملية المراجعة الحالية.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'السبب (اختياري)',
                hintText: 'أدخل سبب الإرجاع',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('إرجاع'),
          ),
        ],
      ),
    );

    final reason = reasonController.text.trim();
    return (
      confirmed ?? false,
      reason.isNotEmpty ? reason : null,
    );
  }

  /// Show accept pricing confirmation dialog
  static Future<bool> showAcceptPricingDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قبول التسعير'),
        content: const Text(
          'هل أنت متأكد من قبول هذا التسعير؟ سيتم اعتماد التسعير وستصبح الحالة "موافق عليه".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('قبول'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// Show confirm pricing dialog
  static Future<bool> showConfirmPricingDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التسعير وإنشاء العقد'),
        content: const Text(
          'هل أنت متأكد من تأكيد هذا التسعير؟ سيتم إنشاء العقد ونقل المشروع إلى مرحلة التنفيذ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// Show confirm contract dialog
  static Future<bool> showConfirmContractDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد العقد ونقل المشروع للتنفيذ'),
        content: const Text(
          'هل أنت متأكد من تأكيد العقد؟ سيتم نقل المشروع إلى مرحلة التنفيذ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// Show return contract to pricing dialog
  static Future<(bool, String?)> showReturnContractToPricingDialog(
    BuildContext context,
  ) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إرجاع العقد للتسعير'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من إرجاع العقد إلى مرحلة التسعير؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'السبب (اختياري)',
                hintText: 'أدخل سبب الإرجاع',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('إرجاع'),
          ),
        ],
      ),
    );

    final reason = reasonController.text.trim();
    return (
      confirmed ?? false,
      reason.isNotEmpty ? reason : null,
    );
  }
}
