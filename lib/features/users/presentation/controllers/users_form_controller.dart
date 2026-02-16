import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cowork/features/users/domain/entities/user_profile.dart';

class SaveUserResult {
  final bool success;
  final bool alreadyExists;
  final String? errorMessage;
  final String? createdUid;

  const SaveUserResult({
    required this.success,
    required this.alreadyExists,
    required this.errorMessage,
    required this.createdUid,
  });

  const SaveUserResult.success({String? createdUid})
      : success = true,
        alreadyExists = false,
        errorMessage = null,
        createdUid = createdUid;

  const SaveUserResult.error(String message)
      : success = false,
        alreadyExists = false,
        errorMessage = message,
        createdUid = null;

  const SaveUserResult.alreadyExists()
      : success = false,
        alreadyExists = true,
        errorMessage = null,
        createdUid = null;
}

final usersFormControllerProvider =
    AsyncNotifierProvider<UsersFormController, void>(UsersFormController.new);

final usersFormFieldsProvider =
    AutoDisposeNotifierProvider<UsersFormFieldsController, UsersFormFieldsState>(
        UsersFormFieldsController.new);

class UsersFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<SaveUserResult> saveUser({
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
    final actorUid = ref.read(authUidProvider).value;
    if (actorUid == null) {
      return const SaveUserResult.error('You must be signed in.');
    }

    if (role != 'admin' && (departmentId == null || departmentId.isEmpty)) {
      return const SaveUserResult.error('Department is required for this role.');
    }

    final firestore = ref.read(firestoreProvider);
    state = const AsyncLoading();
    try {
      final usersCol = firestore.collection('users');

      if (docId.isNotEmpty) {
        final docRef = usersCol.doc(docId);
        final existing = await docRef.get();
        if (!existing.exists) {
          return const SaveUserResult.error('Selected user does not exist.');
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
        state = const AsyncData(null);
        return const SaveUserResult.success();
      }

      if (email.isEmpty || fullName.isEmpty) {
        return const SaveUserResult.error('Full name and email are required.');
      }
      if (password.trim().length < 6) {
        return const SaveUserResult.error('Password must be at least 6 characters.');
      }
      if (photoBytes == null) {
        return const SaveUserResult.error('Photo is required.');
      }

      final callable = FirebaseFunctions.instance.httpsCallable('createUserWithProfile');
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
      if (newUid != null) {
        final photoUrl = await _uploadUserPhoto(newUid, photoBytes);
        await firestore.collection('users').doc(newUid).set(
          {
            'photo_url': photoUrl,
            'updated_at': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      state = const AsyncData(null);
      return SaveUserResult.success(createdUid: newUid);
    } on FirebaseFunctionsException catch (e) {
      state = const AsyncData(null);
      if (e.code == 'already-exists') {
        return const SaveUserResult.alreadyExists();
      }
      return SaveUserResult.error('Save failed: ${e.message ?? e.code}');
    } catch (e) {
      state = const AsyncData(null);
      return SaveUserResult.error('Save failed: $e');
    }
  }

  Future<String> _uploadUserPhoto(String uid, Uint8List bytes) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_avatars')
        .child('$uid.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}

class UsersFormFieldsState {
  final String role;
  final String? selectedDeptId;
  final String? selectedDeptManagerId;
  final bool setDeptManager;
  final bool isActive;
  final Uint8List? photoBytes;
  final String? photoUrl;

  const UsersFormFieldsState({
    required this.role,
    required this.selectedDeptId,
    required this.selectedDeptManagerId,
    required this.setDeptManager,
    required this.isActive,
    required this.photoBytes,
    required this.photoUrl,
  });

  factory UsersFormFieldsState.initial() {
    return const UsersFormFieldsState(
      role: 'employee',
      selectedDeptId: null,
      selectedDeptManagerId: null,
      setDeptManager: true,
      isActive: true,
      photoBytes: null,
      photoUrl: null,
    );
  }

  UsersFormFieldsState copyWith({
    String? role,
    String? selectedDeptId,
    String? selectedDeptManagerId,
    bool? setDeptManager,
    bool? isActive,
    Object? photoBytes = _unset,
    Object? photoUrl = _unset,
  }) {
    return UsersFormFieldsState(
      role: role ?? this.role,
      selectedDeptId: selectedDeptId ?? this.selectedDeptId,
      selectedDeptManagerId: selectedDeptManagerId ?? this.selectedDeptManagerId,
      setDeptManager: setDeptManager ?? this.setDeptManager,
      isActive: isActive ?? this.isActive,
      photoBytes: photoBytes == _unset ? this.photoBytes : photoBytes as Uint8List?,
      photoUrl: photoUrl == _unset ? this.photoUrl : photoUrl as String?,
    );
  }
}

const _unset = Object();

class UsersFormFieldsController extends AutoDisposeNotifier<UsersFormFieldsState> {
  late final TextEditingController docId;
  late final TextEditingController name;
  late final TextEditingController email;
  late final TextEditingController password;
  late final TextEditingController managerIdView;
  late final TextEditingController phone;

  @override
  UsersFormFieldsState build() {
    docId = TextEditingController();
    name = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    managerIdView = TextEditingController();
    phone = TextEditingController();

    ref.onDispose(() {
      docId.dispose();
      name.dispose();
      email.dispose();
      password.dispose();
      managerIdView.dispose();
      phone.dispose();
    });

    return UsersFormFieldsState.initial();
  }

  void clearForm() {
    docId.clear();
    name.clear();
    email.clear();
    password.clear();
    managerIdView.clear();
    phone.clear();
    state = UsersFormFieldsState.initial();
  }

  void applyRole(String value) {
    final actorUid = ref.read(authUidProvider).value;
    if (value == 'manager') {
      managerIdView.text = actorUid ?? '';
    } else if (value == 'employee') {
      managerIdView.text = state.selectedDeptManagerId ?? '';
    } else {
      managerIdView.text = '';
    }
    state = state.copyWith(role: value);
  }

  void setDept(String? deptId) {
    state = state.copyWith(selectedDeptId: deptId);
  }

  void setDeptManager(String? managerId) {
    state = state.copyWith(selectedDeptManagerId: managerId);
    if (state.role == 'employee') {
      managerIdView.text = managerId ?? '';
    }
  }

  void setSetDeptManager(bool value) {
    state = state.copyWith(setDeptManager: value);
  }

  void setActive(bool value) {
    state = state.copyWith(isActive: value);
  }

  void fillFromUser(UserProfile user) {
    docId.text = user.id;
    name.text = user.fullName;
    email.text = user.email;
    password.clear();
    managerIdView.text = user.managerId ?? '';
    phone.text = user.phone ?? '';
    state = state.copyWith(
      role: user.role,
      selectedDeptId: user.departmentId,
      selectedDeptManagerId: user.managerId,
      isActive: user.isActive,
      photoUrl: user.photoUrl,
      photoBytes: null,
    );
  }

  void setPhotoBytes(Uint8List? bytes) {
    state = state.copyWith(photoBytes: bytes);
  }

  void clearPhoto() {
    state = state.copyWith(photoBytes: null, photoUrl: null);
  }
}
