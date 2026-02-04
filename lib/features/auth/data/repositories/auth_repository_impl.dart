import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Stream<String?> authUidChanges() => remote.authUidChanges();

  @override
  Future<void> signInEmailPassword({required String email, required String password}) {
    return remote.signInEmailPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => remote.signOut();

  @override
  Future<AppUser?> getUserProfile(String uid) async {
    final model = await remote.getUserProfile(uid);
    return model?.toEntity();
  }
}
