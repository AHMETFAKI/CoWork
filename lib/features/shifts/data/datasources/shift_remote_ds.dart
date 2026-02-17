import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cowork/features/shifts/data/models/shift_model.dart';

class ShiftRemoteDataSource {
  final FirebaseFirestore firestore;

  ShiftRemoteDataSource({required this.firestore});

  Stream<List<ShiftModel>> watchAttendanceForDepartment(String departmentId) {
    return firestore
        .collection('shift_attendance')
        .where('department_id', isEqualTo: departmentId)
        .orderBy('event_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ShiftModel.fromDoc).toList());
  }

  Stream<List<ShiftModel>> watchAttendanceForDepartmentRoles(
    String departmentId,
    List<String> roles,
  ) {
    return firestore
        .collection('shift_attendance')
        .where('department_id', isEqualTo: departmentId)
        .where('user_role', whereIn: roles)
        .orderBy('event_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ShiftModel.fromDoc).toList());
  }

  Stream<List<ShiftModel>> watchAttendanceForUser(String userId) {
    return firestore
        .collection('shift_attendance')
        .where('user_id', isEqualTo: userId)
        .orderBy('event_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ShiftModel.fromDoc).toList());
  }

  Future<ShiftModel?> getLastAttendanceForUser(String userId) async {
    final snapshot = await firestore
        .collection('shift_attendance')
        .where('user_id', isEqualTo: userId)
        .orderBy('event_at', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return ShiftModel.fromDoc(snapshot.docs.first);
  }

  Future<String> createAttendanceEvent(ShiftModel model) async {
    final ref = firestore.collection('shift_attendance').doc();
    await ref.set(model.toCreateMap());
    return ref.id;
  }
}
