import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cowork/features/tasks/domain/entities/task.dart';

class TaskModel {
  final String id;
  final String departmentId;
  final String assignedToUserId;
  final String assignedByUserId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TaskModel({
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

  factory TaskModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Task doc missing data: ${doc.id}');
    }

    final createdAt = data['created_at'];
    final updatedAt = data['updated_at'];
    final dueAt = data['due_at'];

    return TaskModel(
      id: doc.id,
      departmentId: (data['department_id'] ?? '') as String,
      assignedToUserId: (data['assigned_to_user_id'] ?? '') as String,
      assignedByUserId: (data['assigned_by_user_id'] ?? '') as String,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      status: (data['status'] ?? 'todo') as String,
      priority: (data['priority'] ?? 'medium') as String,
      dueAt: dueAt is Timestamp ? dueAt.toDate() : null,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'department_id': departmentId,
      'assigned_to_user_id': assignedToUserId,
      'assigned_by_user_id': assignedByUserId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_at': dueAt == null ? null : Timestamp.fromDate(dueAt!),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  Task toEntity() {
    return Task(
      id: id,
      departmentId: departmentId,
      assignedToUserId: assignedToUserId,
      assignedByUserId: assignedByUserId,
      title: title,
      description: description,
      status: _parseStatus(status),
      priority: _parsePriority(priority),
      dueAt: dueAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static TaskStatus _parseStatus(String value) {
    return switch (value) {
      'in_progress' => TaskStatus.inProgress,
      'done' => TaskStatus.done,
      'cancelled' => TaskStatus.cancelled,
      _ => TaskStatus.todo,
    };
  }

  static TaskPriority _parsePriority(String value) {
    return switch (value) {
      'low' => TaskPriority.low,
      'high' => TaskPriority.high,
      'urgent' => TaskPriority.urgent,
      _ => TaskPriority.medium,
    };
  }
}
