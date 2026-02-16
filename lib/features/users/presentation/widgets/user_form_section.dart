import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:cowork/features/departments/domain/entities/department.dart';
import 'package:cowork/shared/widgets/async_elevated_button.dart';
import 'package:cowork/features/users/presentation/widgets/user_form_header.dart';
import 'package:cowork/features/users/presentation/widgets/user_photo_picker_row.dart';
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
        UserFormHeader(
          saving: saving,
          docId: docId.text,
          onNew: onNew,
        ),
        UserPhotoPickerRow(
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
          child: AsyncElevatedButton(
            loading: saving,
            onPressed: onSave,
            child: Text(docId.text.isEmpty ? 'Create' : 'Update'),
          ),
        ),
      ],
    );
  }
}
