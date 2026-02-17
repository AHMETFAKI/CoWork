enum TaskStatus { todo, inProgress, done, cancelled }

enum TaskPriority { low, medium, high, urgent }

class Task {
  final String id;
  final String departmentId;
  final String assignedToUserId;
  final String assignedByUserId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.departmentId,
    required this.assignedToUserId,
    required this.assignedByUserId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
