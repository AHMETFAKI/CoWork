import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<String?> authUidChanges();
  Future<void> signInEmailPassword({required String email, required String password});
  Future<void> signOut();
  Future<AppUser?> getUserProfile(String uid);
}
