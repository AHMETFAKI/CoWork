import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cowork/features/users/data/models/save_user_result_model.dart';
import 'package:cowork/features/users/data/models/user_profile_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final FirebaseStorage storage;

  UserRemoteDataSource({
    required this.firestore,
    FirebaseFunctions? functions,
    FirebaseStorage? storage,
  })  : functions = functions ?? FirebaseFunctions.instance,
        storage = storage ?? FirebaseStorage.instance;

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

  Stream<List<UserProfileModel>> watchUsersForDirectory({
    required String uid,
    required String? createdByUserId,
  }) {
    final users = firestore.collection('users');
    final companyAdminUid =
        (createdByUserId != null && createdByUserId.isNotEmpty) ? createdByUserId : uid;

    final streams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[
      users.where(FieldPath.documentId, isEqualTo: companyAdminUid).snapshots(),
      users.where('created_by_user_id', isEqualTo: companyAdminUid).snapshots(),
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

  Future<UserProfileModel?> getUserByEmail(String email) async {
    final snap =
        await firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return UserProfileModel.fromMap(doc.id, doc.data());
  }

  Future<SaveUserResultModel> saveUser({
    required String actorUid,
    required String docId,
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String? departmentId,
    required String? selectedDeptManagerId,
    required String phone,
    required bool isActive,
    required bool setDeptManager,
    required Uint8List? photoBytes,
  }) async {
    try {
      final usersCol = firestore.collection('users');

      if (docId.isNotEmpty) {
        final docRef = usersCol.doc(docId);
        final existing = await docRef.get();
        if (!existing.exists) {
          return const SaveUserResultModel.error('Selected user does not exist.');
        }

        final managerId = switch (role) {
          'manager' => actorUid,
          'employee' => selectedDeptManagerId,
          _ => null,
        };

        final data = <String, dynamic>{
          'full_name': fullName,
          'email': email,
          'role': role,
          'department_id': departmentId,
          'manager_id': managerId,
          'phone': phone,
          'is_active': isActive,
          'updated_at': FieldValue.serverTimestamp(),
        };

        if (photoBytes != null) {
          final photoUrl = await _uploadUserPhoto(docId, photoBytes);
          data['photo_url'] = photoUrl;
        }

        final batch = firestore.batch();
        batch.set(docRef, data, SetOptions(merge: true));

        if (role == 'manager' && setDeptManager && departmentId != null) {
          final deptRef = firestore.collection('departments').doc(departmentId);
          batch.set(
            deptRef,
            {
              'manager_id': docId,
              'updated_at': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }

        await batch.commit();
        return const SaveUserResultModel.success();
      }

      final callable = functions.httpsCallable('createUserWithProfile');
      final result = await callable.call({
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': role,
        'department_id': departmentId,
        'phone': phone,
        'is_active': isActive,
        'set_dept_manager': setDeptManager,
      });
      final data = result.data;
      final newUid = (data is Map && data['uid'] is String) ? data['uid'] as String : null;
      if (newUid != null && photoBytes != null) {
        final photoUrl = await _uploadUserPhoto(newUid, photoBytes);
        await firestore.collection('users').doc(newUid).set(
          {
            'photo_url': photoUrl,
            'updated_at': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      return SaveUserResultModel.success(createdUid: newUid);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists') {
        return const SaveUserResultModel.alreadyExists();
      }
      return SaveUserResultModel.error('Save failed: ${e.message ?? e.code}');
    } catch (e) {
      return SaveUserResultModel.error('Save failed: $e');
    }
  }

  Future<String> _uploadUserPhoto(String uid, Uint8List bytes) async {
    final ref = storage.ref().child('user_avatars').child('$uid.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
