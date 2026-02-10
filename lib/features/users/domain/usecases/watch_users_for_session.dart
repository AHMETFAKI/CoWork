import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class WatchUsersForSession {
  final UserRepository repository;

  WatchUsersForSession(this.repository);

  Stream<List<UserProfile>> call({
    required String uid,
    required String role,
    required String? departmentId,
    required String? createdByUserId,
  }) {
    return repository.watchUsersForSession(
      uid: uid,
      role: role,
      departmentId: departmentId,
      createdByUserId: createdByUserId,
    );
  }
}
