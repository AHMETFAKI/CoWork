import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/department_model.dart';

class DepartmentRemoteDataSource {
  final FirebaseFirestore firestore;

  DepartmentRemoteDataSource({required this.firestore});

  Stream<List<DepartmentModel>> watchDepartments() {
    return firestore.collection('departments').orderBy('name').snapshots().map(
          (snap) => snap.docs.map((doc) => DepartmentModel.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Future<void> createDepartment({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    final docRef = firestore.collection('departments').doc();
    await docRef.set({
      'name': name,
      'description': description,
      'manager_id': null,
      'is_active': isActive,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
