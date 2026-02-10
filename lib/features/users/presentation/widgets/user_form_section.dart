import 'package:flutter/material.dart';

import 'department_selector.dart';
import '../../../departments/domain/entities/department.dart';

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
  final bool saving;
  final Stream<List<Department>> departmentsStream;
  final VoidCallback onNew;
  final VoidCallback onSave;
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
    required this.saving,
    required this.departmentsStream,
    required this.onNew,
    required this.onSave,
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
