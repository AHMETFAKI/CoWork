import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/tasks/domain/entities/task.dart';
import 'package:cowork/features/tasks/domain/repositories/task_repository.dart';

final visibleTasksProvider = StreamProvider<List<Task>>((ref) {
  final user = ref.watch(sessionProvider).asData?.value;
  if (user == null) return const Stream.empty();

  if (user.role == AppRole.admin || user.role == AppRole.manager) {
    if (user.departmentId == null) return const Stream.empty();
    return ref
        .watch(taskRepositoryProvider)
        .watchTasksForDepartment(user.departmentId!);
  }

  return ref.watch(taskRepositoryProvider).watchTasksForAssignee(user.uid);
});

final myTasksProvider = StreamProvider<List<Task>>((ref) {
  final user = ref.watch(sessionProvider).asData?.value;
  if (user == null) return const Stream.empty();
  return ref.watch(taskRepositoryProvider).watchTasksForAssignee(user.uid);
});

final taskControllerProvider =
    AsyncNotifierProvider<TaskController, void>(TaskController.new);

class TaskController extends AsyncNotifier<void> {
  late final TaskRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.watch(taskRepositoryProvider);
  }

  Future<void> createTask({
    required String assignedToUserId,
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueAt,
  }) async {
    final user = ref.read(sessionProvider).asData?.value;
    if (user == null) {
      throw StateError('No session user for createTask');
    }
    if (user.departmentId == null) {
      throw StateError('Missing departmentId for createTask');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.createTask(
        departmentId: user.departmentId!,
        assignedToUserId: assignedToUserId,
        assignedByUserId: user.uid,
        title: title,
        description: description,
        priority: priority,
        dueAt: dueAt,
      );
    });
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.updateTaskStatus(taskId: taskId, status: status);
    });
  }
}
