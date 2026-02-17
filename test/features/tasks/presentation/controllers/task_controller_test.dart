import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/tasks/domain/entities/task.dart';
import 'package:cowork/features/tasks/domain/repositories/task_repository.dart';
import 'package:cowork/features/tasks/presentation/controllers/task_controller.dart';

void main() {
  group('TaskController', () {
    test('createTask calls repository with session values', () async {
      final fakeRepo = _FakeTaskRepository();
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(fakeRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'manager-1',
                name: 'Manager',
                role: AppRole.manager,
                departmentId: 'dept-1',
                createdByUserId: null,
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(taskControllerProvider.future);
      await container.read(taskControllerProvider.notifier).createTask(
        assignedToUserId: 'employee-1',
        title: 'Prepare report',
        description: 'Create weekly report',
        priority: TaskPriority.high,
      );

      expect(fakeRepo.lastCreateDepartmentId, 'dept-1');
      expect(fakeRepo.lastCreateAssignedByUserId, 'manager-1');
      expect(fakeRepo.lastCreateAssignedToUserId, 'employee-1');
      expect(fakeRepo.lastCreateTitle, 'Prepare report');
      expect(fakeRepo.lastCreateDescription, 'Create weekly report');
      expect(fakeRepo.lastCreatePriority, TaskPriority.high);
    });

    test('createTask throws if session has no department', () async {
      final fakeRepo = _FakeTaskRepository();
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(fakeRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'admin-1',
                name: 'Admin',
                role: AppRole.admin,
                departmentId: null,
                createdByUserId: null,
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(taskControllerProvider.future);

      await expectLater(
        container.read(taskControllerProvider.notifier).createTask(
          assignedToUserId: 'employee-1',
          title: 'Title',
          description: 'Description',
          priority: TaskPriority.medium,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}

class _FakeTaskRepository implements TaskRepository {
  String? lastCreateDepartmentId;
  String? lastCreateAssignedToUserId;
  String? lastCreateAssignedByUserId;
  String? lastCreateTitle;
  String? lastCreateDescription;
  TaskPriority? lastCreatePriority;

  @override
  Future<String> createTask({
    required String departmentId,
    required String assignedToUserId,
    required String assignedByUserId,
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueAt,
  }) async {
    lastCreateDepartmentId = departmentId;
    lastCreateAssignedToUserId = assignedToUserId;
    lastCreateAssignedByUserId = assignedByUserId;
    lastCreateTitle = title;
    lastCreateDescription = description;
    lastCreatePriority = priority;
    return 'task-1';
  }

  @override
  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) async {}

  @override
  Stream<List<Task>> watchTasksForAssignee(String assignedToUserId) {
    return const Stream.empty();
  }

  @override
  Stream<List<Task>> watchTasksForDepartment(String departmentId) {
    return const Stream.empty();
  }
}
