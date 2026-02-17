import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/tasks/domain/entities/task.dart';
import 'package:cowork/features/tasks/presentation/controllers/task_controller.dart';
import 'package:cowork/features/users/domain/entities/user_profile.dart';
import 'package:cowork/features/users/presentation/controllers/users_controller.dart';
import 'package:cowork/shared/ui/feedback/app_feedback.dart';
import 'package:cowork/shared/widgets/async_elevated_button.dart';
import 'package:cowork/shared/widgets/app_date_field.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';

class TaskCreatePage extends ConsumerStatefulWidget {
  const TaskCreatePage({super.key});

  @override
  ConsumerState<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends ConsumerState<TaskCreatePage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _dueAt = TextEditingController();
  DateTime? _dueAtValue;

  TaskPriority _priority = TaskPriority.medium;
  String? _assignedToUserId;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _dueAt.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      showErrorSnackBar(context, 'Title is required.');
      return;
    }
    if (_assignedToUserId == null) {
      showErrorSnackBar(context, 'Assignee is required.');
      return;
    }

    final dueAt = _dueAtValue;
    if (_dueAt.text.trim().isNotEmpty && dueAt == null) {
      showErrorSnackBar(context, 'Gecerli bir son tarih girin.');
      return;
    }

    try {
      await ref.read(taskControllerProvider.notifier).createTask(
        assignedToUserId: _assignedToUserId!,
        title: title,
        description: _description.text.trim(),
        priority: _priority,
        dueAt: dueAt,
      );
      if (!mounted) return;
      showSuccessSnackBar(context, 'Task created.');
      context.go(Routes.tasks);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Create failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).asData?.value;
    final users = ref.watch(usersStreamProvider);
    final state = ref.watch(taskControllerProvider);
    final currentUser = session;
    final canCreate =
        currentUser != null &&
        (currentUser.role == AppRole.admin || currentUser.role == AppRole.manager);

    if (!canCreate) {
      return const AppScaffold(
        title: 'Create Task',
        child: Center(child: Text('You are not allowed to create tasks.')),
      );
    }

    return AppScaffold(
      title: 'Create Task',
      child: users.when(
        data: (items) {
          final assignees = _departmentAssignees(items, currentUser!.departmentId);
          if (assignees.isEmpty) {
            return const Center(
              child: Text('No available users in this department.'),
            );
          }

          _assignedToUserId ??= assignees.first.id;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                value: _assignedToUserId,
                items: assignees
                    .map(
                      (user) => DropdownMenuItem<String>(
                        value: user.id,
                        child: Text('${user.fullName} (${user.role})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _assignedToUserId = value),
                decoration: const InputDecoration(labelText: 'Assign To'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                items: const [
                  DropdownMenuItem(
                    value: TaskPriority.low,
                    child: Text('Low'),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.medium,
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.high,
                    child: Text('High'),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.urgent,
                    child: Text('Urgent'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _priority = value);
                },
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              AppDateField(
                controller: _dueAt,
                labelText: 'Due Date',
                onDateChanged: (date) => _dueAtValue = date,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AsyncElevatedButton(
                  loading: state.isLoading,
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  List<UserProfile> _departmentAssignees(
    List<UserProfile> items,
    String? departmentId,
  ) {
    return items
        .where((user) => user.isActive)
        .where((user) => user.departmentId == departmentId)
        .toList();
  }
}
