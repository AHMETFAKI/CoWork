import 'package:flutter/material.dart';

import '../../../departments/domain/entities/department.dart';

class DepartmentOption {
  final String id;
  final String name;
  final String? managerId;

  const DepartmentOption({
    required this.id,
    required this.name,
    required this.managerId,
  });
}

class DepartmentSelector extends StatelessWidget {
  final Stream<List<Department>> stream;
  final String? selectedDeptId;
  final String role;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String?> onManagerResolved;

  const DepartmentSelector({
    super.key,
    required this.stream,
    required this.selectedDeptId,
    required this.role,
    required this.onChanged,
    required this.onManagerResolved,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Department>>(
      stream: stream,
      builder: (context, snapshot) {
        final departments = snapshot.data ?? [];
        final items = departments.map((dept) {
          final name = dept.name.isNotEmpty ? dept.name : dept.id;
          return DepartmentOption(id: dept.id, name: name, managerId: dept.managerId);
        }).toList();

        final selected = items.firstWhere(
          (item) => item.id == selectedDeptId,
          orElse: () => const DepartmentOption(id: '', name: '', managerId: null),
        );

        return DropdownButtonFormField<String>(
          value: selected.id.isEmpty ? null : selected.id,
          items: items
              .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name)))
              .toList(),
          onChanged: (value) {
            onChanged(value);
            final match = items.firstWhere(
              (item) => item.id == value,
              orElse: () => const DepartmentOption(id: '', name: '', managerId: null),
            );
            onManagerResolved(match.managerId);
          },
          decoration: InputDecoration(
            labelText: role == 'admin' ? 'Department (optional)' : 'Department *',
          ),
        );
      },
    );
  }
}
