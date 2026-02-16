import 'package:flutter/material.dart';

Future<String?> showOptionalNoteDialog(
  BuildContext context, {
  required String title,
  String labelText = 'Note (optional)',
  String skipText = 'Skip',
  String saveText = 'Save',
}) async {
  final controller = TextEditingController();
  final result = await showDialog<String?>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: labelText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text(skipText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              controller.text.trim().isEmpty ? null : controller.text.trim(),
            ),
            child: Text(saveText),
          ),
        ],
      );
    },
  );
  controller.dispose();
  return result;
}
