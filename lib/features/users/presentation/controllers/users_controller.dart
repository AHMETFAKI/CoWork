import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/watch_users_for_session.dart';

final watchUsersUseCaseProvider = Provider<WatchUsersForSession>((ref) {
  return WatchUsersForSession(ref.watch(userRepositoryProvider));
});

final usersStreamProvider = StreamProvider<List<UserProfile>>((ref) {
  final session = ref.watch(sessionProvider).asData?.value;
  if (session == null) return const Stream.empty();

  final role = switch (session.role) {
    AppRole.admin => 'admin',
    AppRole.manager => 'manager',
    AppRole.employee => 'employee',
  };

  return ref.watch(watchUsersUseCaseProvider).call(
        uid: session.uid,
        role: role,
        departmentId: session.departmentId,
        createdByUserId: session.createdByUserId,
      );
});
