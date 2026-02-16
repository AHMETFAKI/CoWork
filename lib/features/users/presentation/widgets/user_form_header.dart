import 'package:flutter/material.dart';

class UserFormHeader extends StatelessWidget {
  final bool saving;
  final String docId;
  final VoidCallback onNew;

  const UserFormHeader({
    super.key,
    required this.saving,
    required this.docId,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Kullanici Kaydi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: saving ? null : onNew,
              child: const Text('Yeni'),
            )
          ],
        ),
        if (docId.isNotEmpty) ...[
          const Text(
            'Duzenleme modu',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'DocID: $docId',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
