import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repo;
  SignIn(this.repo);

  Future<void> call(String email, String password) {
    return repo.signInEmailPassword(email: email, password: password);
  }
}
