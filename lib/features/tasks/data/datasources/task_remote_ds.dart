import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cowork/features/tasks/data/models/task_model.dart';

class TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSource({required this.firestore});

  Stream<List<TaskModel>> watchTasksForDepartment(String departmentId) {
    return firestore
        .collection('tasks')
        .where('department_id', isEqualTo: departmentId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskModel.fromDoc).toList());
  }

  Stream<List<TaskModel>> watchTasksForAssignee(String assignedToUserId) {
    return firestore
        .collection('tasks')
        .where('assigned_to_user_id', isEqualTo: assignedToUserId)
        .orderBy('status')
        .orderBy('due_at')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskModel.fromDoc).toList());
  }

  Future<String> createTask(TaskModel model) async {
    final ref = firestore.collection('tasks').doc();
    await ref.set(model.toCreateMap());
    return ref.id;
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required String status,
  }) {
    return firestore.collection('tasks').doc(taskId).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
