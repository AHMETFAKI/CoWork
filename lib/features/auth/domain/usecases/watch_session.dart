import '../repositories/auth_repository.dart';

class WatchSession {
  final AuthRepository repo;
  WatchSession(this.repo);

  Stream<String?> call() => repo.authUidChanges();
}
