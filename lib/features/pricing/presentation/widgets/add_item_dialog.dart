import 'package:flutter/material.dart';

/// Dialog for adding a new pricing item or sub-item
class AddItemDialog extends StatelessWidget {
  final String title;
  final String labelText;
  final String hintText;

  const AddItemDialog({
    super.key,
    required this.title,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(labelText: labelText, hintText: hintText),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, nameController.text),
          child: const Text('إضافة'),
        ),
      ],
    );
  }

  /// Show dialog for adding a pricing item
  static Future<String?> showAddItemDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const AddItemDialog(
        title: 'إضافة بند جديد',
        labelText: 'اسم الفئة',
        hintText: 'أدخل اسم الفئة',
      ),
    );
  }

  /// Show dialog for adding a sub-item
  static Future<String?> showAddSubItemDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const AddItemDialog(
        title: 'إضافة عنصر جديدة',
        labelText: 'اسم العنصر',
        hintText: 'أدخل اسم العنصر',
      ),
    );
  }
}
