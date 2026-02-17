import 'package:cowork/features/tasks/domain/entities/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasksForDepartment(String departmentId);

  Stream<List<Task>> watchTasksForAssignee(String assignedToUserId);

  Future<String> createTask({
    required String departmentId,
    required String assignedToUserId,
    required String assignedByUserId,
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueAt,
  });

  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  });
}
