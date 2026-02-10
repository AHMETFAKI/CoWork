import '../entities/user_profile.dart';

abstract class UserRepository {
  Stream<List<UserProfile>> watchUsersForSession({
    required String uid,
    required String role,
    required String? departmentId,
    required String? createdByUserId,
  });

  Future<UserProfile?> getUserById(String uid);
}
