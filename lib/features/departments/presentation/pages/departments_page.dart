import 'package:cowork/features/departments/presentation/controllers/departments_controller.dart' hide departmentsFormControllerProvider, departmentsStreamProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_scaffold.dart';
import '../widgets/department_form_section.dart';
import '../widgets/department_list_section.dart';
import '../controllers/departments_controller.dart';

class DepartmentsPage extends ConsumerStatefulWidget {
  const DepartmentsPage({super.key});

  @override
  ConsumerState<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends ConsumerState<DepartmentsPage> {
  bool _deptSaving = false;

  Future<void> _createDepartment() async {
    setState(() => _deptSaving = true);
    final error = await ref.read(departmentsFormControllerProvider.notifier).createDepartment(
          name: ref.read(departmentsFormFieldsProvider.notifier).name.text,
          description: ref.read(departmentsFormFieldsProvider.notifier).description.text,
          isActive: ref.read(departmentsFormFieldsProvider).isActive,
        );

    if (!mounted) return;
    setState(() => _deptSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ref.read(departmentsFormFieldsProvider.notifier).clearForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Departman olusturuldu.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final departmentsStream = ref.watch(departmentsStreamProvider);
    final formState = ref.watch(departmentsFormControllerProvider);
    final fieldsState = ref.watch(departmentsFormFieldsProvider);
    final fields = ref.read(departmentsFormFieldsProvider.notifier);

    return AppScaffold(
      title: 'Departmanlar',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DepartmentFormSection(
            name: fields.name,
            description: fields.description,
            isActive: fieldsState.isActive,
            saving: _deptSaving || formState.isLoading,
            onSubmit: _createDepartment,
            onActiveChanged: fields.setActive,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          DepartmentListSection(
            stream: departmentsStream.when(
              data: (items) => Stream.value(items),
              error: (err, _) => Stream.error(err),
              loading: () => const Stream.empty(),
            ),
          ),
        ],
      ),
    );
  }
}
