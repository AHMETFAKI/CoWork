import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/users/domain/entities/save_user_result.dart';
import 'package:cowork/features/users/domain/entities/user_profile.dart';

final usersFormControllerProvider =
    AsyncNotifierProvider<UsersFormController, void>(UsersFormController.new);

final usersFormFieldsProvider =
    NotifierProvider.autoDispose<UsersFormFieldsController, UsersFormFieldsState>(
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

    state = const AsyncLoading();
    try {
      if (email.isEmpty || fullName.isEmpty) {
        return const SaveUserResult.error('Full name and email are required.');
      }
      if (docId.isEmpty && password.trim().length < 6) {
        return const SaveUserResult.error('Password must be at least 6 characters.');
      }
      if (docId.isEmpty && photoBytes == null) {
        return const SaveUserResult.error('Photo is required.');
      }

      final repo = ref.read(userRepositoryProvider);
      final result = await repo.saveUser(
        actorUid: actorUid,
        docId: docId,
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        departmentId: departmentId,
        selectedDeptManagerId: selectedDeptManagerId,
        phone: phone,
        isActive: isActive,
        setDeptManager: setDeptManager,
        photoBytes: photoBytes,
      );
      state = const AsyncData(null);
      return result;
    } catch (e) {
      state = const AsyncData(null);
      return SaveUserResult.error('Save failed: $e');
    }
  }

  Future<UserProfile?> loadUserByEmail(String email) async {
    if (email.trim().isEmpty) return null;
    final repo = ref.read(userRepositoryProvider);
    return repo.getUserByEmail(email.trim());
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

class UsersFormFieldsController extends Notifier<UsersFormFieldsState> {
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
