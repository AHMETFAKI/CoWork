import 'package:cowork/features/tasks/data/datasources/task_remote_ds.dart';
import 'package:cowork/features/tasks/data/models/task_model.dart';
import 'package:cowork/features/tasks/domain/entities/task.dart';
import 'package:cowork/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remote;

  TaskRepositoryImpl(this.remote);

  @override
  Stream<List<Task>> watchTasksForDepartment(String departmentId) {
    return remote
        .watchTasksForDepartment(departmentId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<List<Task>> watchTasksForAssignee(String assignedToUserId) {
    return remote
        .watchTasksForAssignee(assignedToUserId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<String> createTask({
    required String departmentId,
    required String assignedToUserId,
    required String assignedByUserId,
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueAt,
  }) {
    final model = TaskModel(
      id: '',
      departmentId: departmentId,
      assignedToUserId: assignedToUserId,
      assignedByUserId: assignedByUserId,
      title: title,
      description: description,
      status: TaskStatus.todo.name,
      priority: priority.name,
      dueAt: dueAt,
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    return remote.createTask(model);
  }

  @override
  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) {
    final statusText = switch (status) {
      TaskStatus.todo => 'todo',
      TaskStatus.inProgress => 'in_progress',
      TaskStatus.done => 'done',
      TaskStatus.cancelled => 'cancelled',
    };

    return remote.updateTaskStatus(taskId: taskId, status: statusText);
  }
}
