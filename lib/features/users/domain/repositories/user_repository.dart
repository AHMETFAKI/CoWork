import 'package:cowork/features/users/domain/entities/user_profile.dart';
import 'package:cowork/features/users/domain/entities/save_user_result.dart';
import 'dart:typed_data';

abstract class UserRepository {
  Stream<List<UserProfile>> watchUsersForSession({
    required String uid,
    required String role,
    required String? departmentId,
    required String? createdByUserId,
  });

  Stream<List<UserProfile>> watchUsersForDirectory({
    required String uid,
    required String? createdByUserId,
  });

  Future<UserProfile?> getUserById(String uid);
  Future<UserProfile?> getUserByEmail(String email);
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
  });
}
