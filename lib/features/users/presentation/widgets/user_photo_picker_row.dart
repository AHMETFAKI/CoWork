import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:cowork/shared/widgets/resolved_avatar.dart';

class UserPhotoPickerRow extends StatelessWidget {
  final Uint8List? photoBytes;
  final String? photoUrl;
  final VoidCallback onPickPhoto;
  final VoidCallback onClearPhoto;

  const UserPhotoPickerRow({
    super.key,
    required this.photoBytes,
    required this.photoUrl,
    required this.onPickPhoto,
    required this.onClearPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _UserPhotoAvatar(
          photoBytes: photoBytes,
          photoUrl: photoUrl,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil Fotografi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onPickPhoto,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Sec'),
                  ),
                  const SizedBox(width: 8),
                  if (photoBytes != null || (photoUrl != null && photoUrl!.isNotEmpty))
                    TextButton(
                      onPressed: onClearPhoto,
                      child: const Text('Kaldir'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserPhotoAvatar extends StatelessWidget {
  final Uint8List? photoBytes;
  final String? photoUrl;

  const _UserPhotoAvatar({
    required this.photoBytes,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: 28,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      child: const Icon(Icons.person_outline),
    );

    if (photoBytes != null) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        backgroundImage: MemoryImage(photoBytes!),
      );
    }

    if (photoUrl == null || photoUrl!.isEmpty) {
      return fallback;
    }

    return ResolvedAvatar(
      photoUrl: photoUrl,
      radius: 28,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      fallback: const Icon(Icons.person_outline),
    );
  }
}
