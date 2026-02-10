import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSource({required this.firestore});

  Stream<List<UserProfileModel>> watchUsersForSession({
    required String uid,
    required String role,
    required String? departmentId,
    required String? createdByUserId,
  }) {
    final users = firestore.collection('users');

    if (role == 'admin') {
      return users
          .where('created_by_user_id', isEqualTo: uid)
          .orderBy('full_name')
          .snapshots()
          .map((snap) => snap.docs
              .where((doc) => doc.id != uid)
              .map((doc) => UserProfileModel.fromMap(doc.id, doc.data()))
              .toList());
    }

    if (role == 'employee') {
      return users
          .where('department_id', isEqualTo: departmentId)
          .orderBy('full_name')
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => UserProfileModel.fromMap(doc.id, doc.data()))
              .toList());
    }

    final streams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[
      users.where(FieldPath.documentId, isEqualTo: uid).snapshots(),
      if (createdByUserId != null && createdByUserId.isNotEmpty)
        users.where(FieldPath.documentId, isEqualTo: createdByUserId).snapshots(),
      users.where('manager_id', isEqualTo: uid).snapshots(),
    ];

    return Stream<List<UserProfileModel>>.multi((controller) {
      final latest = List<QuerySnapshot<Map<String, dynamic>>?>.filled(streams.length, null);
      final subs = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

      void emitIfReady() {
        if (latest.any((snap) => snap == null)) return;
        final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final seen = <String>{};
        for (final snap in latest) {
          for (final doc in snap!.docs) {
            if (seen.add(doc.id)) {
              allDocs.add(doc);
            }
          }
        }
        allDocs.sort((a, b) {
          final aName = (a.data()['full_name'] ?? '') as String;
          final bName = (b.data()['full_name'] ?? '') as String;
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });
        controller.add(
          allDocs.map((doc) => UserProfileModel.fromMap(doc.id, doc.data())).toList(),
        );
      }

      for (var i = 0; i < streams.length; i++) {
        subs.add(
          streams[i].listen(
            (snap) {
              latest[i] = snap;
              emitIfReady();
            },
            onError: controller.addError,
          ),
        );
      }

      controller.onCancel = () {
        for (final sub in subs) {
          sub.cancel();
        }
      };
    });
  }

  Future<UserProfileModel?> getUserById(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return UserProfileModel.fromMap(doc.id, data);
  }
}
