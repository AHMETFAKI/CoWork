import 'package:flutter/material.dart';

class DepartmentFormSection extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController description;
  final bool isActive;
  final bool saving;
  final VoidCallback onSubmit;
  final ValueChanged<bool> onActiveChanged;

  const DepartmentFormSection({
    super.key,
    required this.name,
    required this.description,
    required this.isActive,
    required this.saving,
    required this.onSubmit,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Departman Olustur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Departman Adi *'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: description,
          decoration: const InputDecoration(labelText: 'Aciklama'),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Aktif'),
          value: isActive,
          onChanged: onActiveChanged,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: saving ? null : onSubmit,
            child: saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Departman Olustur'),
          ),
        ),
      ],
    );
  }
}
