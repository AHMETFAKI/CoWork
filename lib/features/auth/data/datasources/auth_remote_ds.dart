import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource({
    required this.auth,
    required this.firestore,
  });

  Stream<String?> authUidChanges() {
    return auth.authStateChanges().map((u) => u?.uid);
  }

  Future<void> signInEmailPassword({required String email, required String password}) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<AppUserModel?> getUserProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return AppUserModel.fromMap(uid, data);
  }

  Future<void> createEmployerAccount({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
    String? phone,
  }) async {
    UserCredential credential;
    try {
      credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }

    final uid = credential.user?.uid;
    if (uid == null) {
      throw StateError('User creation failed.');
    }

    final deptRef = firestore.collection('departments').doc();
    final userRef = firestore.collection('users').doc(uid);
    final logRef = firestore.collection('audit_logs').doc();

    final batch = firestore.batch();
    batch.set(deptRef, {
      'name': departmentName,
      'description': '',
      'manager_id': uid,
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    batch.set(userRef, {
      'full_name': fullName,
      'email': email,
      'role': 'admin',
      'department_id': deptRef.id,
      'manager_id': null,
      'created_by_user_id': uid,
      'phone': phone ?? '',
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'last_login_at': FieldValue.serverTimestamp(),
    });
    batch.set(logRef, {
      'actor_user_id': uid,
      'department_id': deptRef.id,
      'entity_type': 'bootstrap',
      'entity_id': uid,
      'action': 'create_admin',
      'metadata_json': '{"flow":"employer_signup"}',
      'created_at': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
    } catch (e) {
      await credential.user?.delete();
      rethrow;
    }
  }
}
