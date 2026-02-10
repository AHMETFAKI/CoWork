import 'package:flutter/material.dart';

import '../../domain/entities/department.dart';

class DepartmentListSection extends StatelessWidget {
  final Stream<List<Department>> stream;

  const DepartmentListSection({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Departmanlar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Department>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final departments = snapshot.data!;
            if (departments.isEmpty) return const Text('No departments found.');

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: departments.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final dept = departments[index];
                final name = dept.name.isNotEmpty ? dept.name : '-';
                final desc = dept.description;
                final managerId = dept.managerId ?? '-';
                return ListTile(
                  title: Text(name),
                  subtitle: Text(
                    'DocID: ${dept.id}\nmanager: $managerId\n$desc',
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
