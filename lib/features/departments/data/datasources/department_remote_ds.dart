import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cowork/features/departments/data/models/department_model.dart';

class DepartmentRemoteDataSource {
  final FirebaseFirestore firestore;

  DepartmentRemoteDataSource({required this.firestore});

  Stream<List<DepartmentModel>> watchDepartments({
    required String uid,
    required String role,
    required String? departmentId,
  }) {
    final departments = firestore.collection('departments');

    if (role == 'admin') {
      return departments
          .where('created_by_user_id', isEqualTo: uid)
          .orderBy('name')
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((doc) => DepartmentModel.fromMap(doc.id, doc.data())).toList(),
          );
    }

    if (role == 'manager' && departmentId != null && departmentId.isNotEmpty) {
      return departments
          .where(FieldPath.documentId, isEqualTo: departmentId)
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((doc) => DepartmentModel.fromMap(doc.id, doc.data())).toList(),
          );
    }

    return const Stream.empty();
  }

  Future<void> createDepartment({
    required String name,
    required String description,
    required bool isActive,
    required String createdByUserId,
  }) async {
    final docRef = firestore.collection('departments').doc();
    await docRef.set({
      'name': name,
      'description': description,
      'manager_id': null,
      'created_by_user_id': createdByUserId,
      'is_active': isActive,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
