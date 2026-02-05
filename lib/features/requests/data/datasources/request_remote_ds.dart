import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/request_model.dart';

class RequestRemoteDataSource {
  final FirebaseFirestore firestore;

  RequestRemoteDataSource({required this.firestore});

  Stream<List<RequestModel>> watchRequestsForUser(String uid) {
    return firestore
        .collection('requests')
        .where('created_by_user_id', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(RequestModel.fromDoc).toList());
  }

  Stream<List<RequestModel>> watchRequestsForDepartment(String departmentId) {
    return firestore
        .collection('requests')
        .where('department_id', isEqualTo: departmentId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(RequestModel.fromDoc).toList());
  }

  Future<String> createRequest(RequestModel model) async {
    final ref = firestore.collection('requests').doc();
    await ref.set(model.toCreateMap());
    return ref.id;
  }

  Future<void> updateStatus({
    required String requestId,
    required String status,
    required String reviewerUserId,
    String? comment,
  }) async {
    final batch = firestore.batch();
    final requestRef = firestore.collection('requests').doc(requestId);
    final approvalRef = firestore.collection('request_approvals').doc();

    batch.update(requestRef, {
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });

    batch.set(approvalRef, {
      'request_id': requestId,
      'reviewer_user_id': reviewerUserId,
      'action': status,
      'comment': comment,
      'reviewed_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
