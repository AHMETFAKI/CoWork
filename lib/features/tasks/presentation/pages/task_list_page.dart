import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/tasks/domain/entities/task.dart';
import 'package:cowork/features/tasks/presentation/controllers/task_controller.dart';
import 'package:cowork/shared/ui/feedback/app_feedback.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(visibleTasksProvider);
    final session = ref.watch(sessionProvider).asData?.value;
    final canCreate =
        session != null &&
        (session.role == AppRole.admin || session.role == AppRole.manager);

    return AppScaffold(
      title: 'Tasks',
      child: tasks.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = items[index];
              return _TaskCard(task: task);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.go(Routes.taskCreate),
              label: const Text('Create Task'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskControllerProvider);
    final session = ref.watch(sessionProvider).asData?.value;
    final canUpdateStatus =
        session != null &&
        (session.role == AppRole.admin || session.role == AppRole.manager);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(task.description),
            const SizedBox(height: 6),
            Text('Priority: ${_priorityLabel(task.priority)}'),
            Text('Status: ${_statusLabel(task.status)}'),
            Text(
              'Due: ${task.dueAt == null ? '-' : _formatDate(task.dueAt!)}',
            ),
            if (canUpdateStatus) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<TaskStatus>(
                  enabled: !state.isLoading,
                  onSelected: (status) => _onStatusSelected(
                    context: context,
                    ref: ref,
                    status: status,
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: TaskStatus.todo,
                      child: Text('To Do'),
                    ),
                    PopupMenuItem(
                      value: TaskStatus.inProgress,
                      child: Text('In Progress'),
                    ),
                    PopupMenuItem(
                      value: TaskStatus.done,
                      child: Text('Done'),
                    ),
                    PopupMenuItem(
                      value: TaskStatus.cancelled,
                      child: Text('Cancelled'),
                    ),
                  ],
                  child: const Text('Change Status'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onStatusSelected({
    required BuildContext context,
    required WidgetRef ref,
    required TaskStatus status,
  }) async {
    try {
      await ref
          .read(taskControllerProvider.notifier)
          .updateTaskStatus(taskId: task.id, status: status);
      if (!context.mounted) return;
      showSuccessSnackBar(context, 'Task status updated.');
    } catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, 'Update failed: $e');
    }
  }

  static String _priorityLabel(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => 'Low',
      TaskPriority.medium => 'Medium',
      TaskPriority.high => 'High',
      TaskPriority.urgent => 'Urgent',
    };
  }

  static String _statusLabel(TaskStatus status) {
    return switch (status) {
      TaskStatus.todo => 'To Do',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.done => 'Done',
      TaskStatus.cancelled => 'Cancelled',
    };
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
