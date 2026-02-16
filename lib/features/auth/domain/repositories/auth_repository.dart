import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'dart:typed_data';

abstract class AuthRepository {
  Stream<String?> authUidChanges();
  Future<void> signInEmailPassword({required String email, required String password});
  Future<void> signOut();
  Future<AppUser?> getUserProfile(String uid);
  Stream<AppUser?> watchUserProfile(String uid);
  Future<void> createEmployerAccount({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
    String? phone,
    Uint8List? photoBytes,
  });
}
