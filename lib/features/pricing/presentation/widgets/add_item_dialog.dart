import 'package:flutter/material.dart';

import '../../../../core/widgets/dialog_keyboard_actions.dart';

class AddSubItemDialogResult {
  const AddSubItemDialogResult({required this.name, this.description});

  final String name;
  final String? description;
}

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
    void submit() {
      final name = nameController.text.trim();
      if (name.isNotEmpty) {
        Navigator.pop(context, name);
      }
    }

    return DialogKeyboardActions(
      onSubmit: submit,
      onClose: () => Navigator.pop(context),
      child: AlertDialog(
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
          TextButton(onPressed: submit, child: const Text('إضافة')),
        ],
      ),
    );
  }

  /// Show dialog for adding a pricing item
  static Future<String?> showAddItemDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const AddItemDialog(
        title: 'إضافة بند جديد',
        labelText: 'اسم بند',
        hintText: 'أدخل اسم البند',
      ),
    );
  }

  /// Show dialog for adding a sub-item
  static Future<AddSubItemDialogResult?> showAddSubItemDialog(
    BuildContext context,
  ) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final dialog = showDialog<AddSubItemDialogResult>(
      context: context,
      builder: (context) {
        void submit() {
          final name = nameController.text.trim();
          final description = descriptionController.text.trim();

          if (name.isNotEmpty) {
            Navigator.pop(
              context,
              AddSubItemDialogResult(
                name: name,
                description: description.isEmpty ? null : description,
              ),
            );
          }
        }

        return DialogKeyboardActions(
          onSubmit: submit,
          onClose: () => Navigator.pop(context),
          child: AlertDialog(
            title: const Text('إضافة بند فرعي جديد'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان البند الفرعي',
                      hintText: 'أدخل عنوان البند الفرعي',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'وصف البند الفرعي',
                      hintText: 'أدخل وصف البند الفرعي',
                    ),
                    minLines: 2,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(onPressed: submit, child: const Text('إضافة')),
            ],
          ),
        );
      },
    );

    return dialog.whenComplete(() {
      nameController.dispose();
      descriptionController.dispose();
    });
  }
}
