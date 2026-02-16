import 'package:cowork/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repo;
  SignOut(this.repo);

  Future<void> call() => repo.signOut();
}
