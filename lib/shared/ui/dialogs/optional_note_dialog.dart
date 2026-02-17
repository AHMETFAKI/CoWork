import 'package:flutter/material.dart';

Future<String?> showOptionalNoteDialog(
  BuildContext context, {
  required String title,
  String labelText = 'Note (optional)',
  String skipText = 'Skip',
  String saveText = 'Save',
}) async {
  return showDialog<String?>(
    context: context,
    builder: (dialogContext) {
      return _OptionalNoteDialog(
        title: title,
        labelText: labelText,
        skipText: skipText,
        saveText: saveText,
      );
    },
  );
}

class _OptionalNoteDialog extends StatefulWidget {
  const _OptionalNoteDialog({
    required this.title,
    required this.labelText,
    required this.skipText,
    required this.saveText,
  });

  final String title;
  final String labelText;
  final String skipText;
  final String saveText;

  @override
  State<_OptionalNoteDialog> createState() => _OptionalNoteDialogState();
}

class _OptionalNoteDialogState extends State<_OptionalNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final note = _controller.text.trim();
    Navigator.of(context).pop(note.isEmpty ? null : note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: widget.labelText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(widget.skipText),
        ),
        ElevatedButton(onPressed: _save, child: Text(widget.saveText)),
      ],
    );
  }
}
