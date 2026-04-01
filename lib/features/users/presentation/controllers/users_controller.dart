import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/users/domain/entities/user_profile.dart';
import 'package:cowork/features/users/domain/usecases/watch_users_for_session.dart';

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

final usersDirectoryStreamProvider = StreamProvider<List<UserProfile>>((ref) {
  final session = ref.watch(sessionProvider).asData?.value;
  if (session == null) return const Stream.empty();

  return ref.watch(userRepositoryProvider).watchUsersForDirectory(
        uid: session.uid,
        createdByUserId: session.createdByUserId,
      );
});
