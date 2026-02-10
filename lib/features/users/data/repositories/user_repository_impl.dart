import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_ds.dart';

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
}
