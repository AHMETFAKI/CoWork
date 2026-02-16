import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:cowork/features/departments/domain/entities/department.dart';
import 'department_selector.dart';

class UserFormSection extends StatelessWidget {
  final TextEditingController docId;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController managerIdView;
  final TextEditingController phone;
  final String role;
  final String? selectedDeptId;
  final bool setDeptManager;
  final bool isActive;
  final Uint8List? photoBytes;
  final String? photoUrl;
  final bool saving;
  final Stream<List<Department>> departmentsStream;
  final VoidCallback onNew;
  final VoidCallback onSave;
  final VoidCallback onPickPhoto;
  final VoidCallback onClearPhoto;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String?> onDeptChanged;
  final ValueChanged<String?> onDeptManagerResolved;
  final ValueChanged<bool> onSetDeptManagerChanged;
  final ValueChanged<bool> onActiveChanged;

  const UserFormSection({
    super.key,
    required this.docId,
    required this.name,
    required this.email,
    required this.password,
    required this.managerIdView,
    required this.phone,
    required this.role,
    required this.selectedDeptId,
    required this.setDeptManager,
    required this.isActive,
    required this.photoBytes,
    required this.photoUrl,
    required this.saving,
    required this.departmentsStream,
    required this.onNew,
    required this.onSave,
    required this.onPickPhoto,
    required this.onClearPhoto,
    required this.onRoleChanged,
    required this.onDeptChanged,
    required this.onDeptManagerResolved,
    required this.onSetDeptManagerChanged,
    required this.onActiveChanged,
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
        if (docId.text.isNotEmpty) ...[
          const Text(
            'Duzenleme modu',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'DocID: ${docId.text}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
        ],
        _PhotoPickerRow(
          photoBytes: photoBytes,
          photoUrl: photoUrl,
          onPickPhoto: onPickPhoto,
          onClearPhoto: onClearPhoto,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: email,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 12),
        if (docId.text.isEmpty) ...[
          TextField(
            controller: password,
            decoration: const InputDecoration(labelText: 'Password (new user only)'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
        ],
        DropdownButtonFormField<String>(
          value: role,
          items: const [
            DropdownMenuItem(value: 'admin', child: Text('admin')),
            DropdownMenuItem(value: 'manager', child: Text('manager')),
            DropdownMenuItem(value: 'employee', child: Text('employee')),
          ],
          onChanged: (value) {
            if (value == null) return;
            onRoleChanged(value);
          },
          decoration: const InputDecoration(labelText: 'Role'),
        ),
        const SizedBox(height: 12),
        DepartmentSelector(
          stream: departmentsStream,
          selectedDeptId: selectedDeptId,
          role: role,
          onChanged: onDeptChanged,
          onManagerResolved: onDeptManagerResolved,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: managerIdView,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Manager Id (auto: current user)',
          ),
        ),
        if (role == 'manager') ...[
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Set as department manager'),
            value: setDeptManager,
            onChanged: onSetDeptManagerChanged,
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: phone,
          decoration: const InputDecoration(labelText: 'Phone'),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Active'),
          value: isActive,
          onChanged: onActiveChanged,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: saving ? null : onSave,
            child: saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(docId.text.isEmpty ? 'Create' : 'Update'),
          ),
        ),
      ],
    );
  }
}

class _PhotoPickerRow extends StatelessWidget {
  final Uint8List? photoBytes;
  final String? photoUrl;
  final VoidCallback onPickPhoto;
  final VoidCallback onClearPhoto;

  const _PhotoPickerRow({
    required this.photoBytes,
    required this.photoUrl,
    required this.onPickPhoto,
    required this.onClearPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PhotoAvatar(
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
                  if (photoBytes != null ||
                      (photoUrl != null && photoUrl!.isNotEmpty))
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

class _PhotoAvatar extends StatelessWidget {
  final Uint8List? photoBytes;
  final String? photoUrl;

  const _PhotoAvatar({
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

    if (photoUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        backgroundImage: NetworkImage(photoUrl!),
      );
    }

    if (photoUrl!.startsWith('gs://')) {
      return FutureBuilder<String>(
        future: FirebaseStorage.instance.refFromURL(photoUrl!).getDownloadURL(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return fallback;
          return CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            backgroundImage: NetworkImage(snapshot.data!),
          );
        },
      );
    }

    return fallback;
  }
}
