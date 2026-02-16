import 'package:cowork/features/users/domain/entities/user_profile.dart';
import 'package:cowork/features/users/domain/entities/save_user_result.dart';
import 'package:cowork/features/users/domain/repositories/user_repository.dart';
import 'package:cowork/features/users/data/datasources/user_remote_ds.dart';
import 'dart:typed_data';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;

  UserRepositoryImpl(this.remote);

  @override
  Stream<List<UserProfile>> watchUsersForSession({
    required String uid,
    required String role,
    required String? departmentId,
    required String? createdByUserId,
  }) {
    return remote
        .watchUsersForSession(
          uid: uid,
          role: role,
          departmentId: departmentId,
          createdByUserId: createdByUserId,
        )
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<UserProfile?> getUserById(String uid) async {
    final model = await remote.getUserById(uid);
    return model?.toEntity();
  }

  @override
  Future<UserProfile?> getUserByEmail(String email) async {
    final model = await remote.getUserByEmail(email);
    return model?.toEntity();
  }

  @override
  Future<SaveUserResult> saveUser({
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
    final model = await remote.saveUser(
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
    return model.toEntity();
  }
}
