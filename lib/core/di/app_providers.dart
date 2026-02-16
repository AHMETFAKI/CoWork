import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:cowork/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/auth/domain/repositories/auth_repository.dart';
import 'package:cowork/features/departments/data/datasources/department_remote_ds.dart';
import 'package:cowork/features/departments/data/repositories/department_repository_impl.dart';
import 'package:cowork/features/departments/domain/repositories/department_repository.dart';
import 'package:cowork/features/requests/data/datasources/request_remote_ds.dart';
import 'package:cowork/features/requests/data/repositories/request_repository_impl.dart';
import 'package:cowork/features/requests/domain/repositories/request_repository.dart';
import 'package:cowork/features/users/data/datasources/user_remote_ds.dart';
import 'package:cowork/features/users/data/repositories/user_repository_impl.dart';
import 'package:cowork/features/users/domain/repositories/user_repository.dart';
import 'package:cowork/shared/data/services/firebase_photo_url_resolver.dart';
import 'package:cowork/shared/domain/services/photo_url_resolver.dart';
import 'package:cowork/shared/domain/usecases/resolve_photo_url.dart';

// Firebase
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Auth
final authRemoteDsProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDsProvider));
});

// Users
final userRemoteDsProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(firestore: ref.watch(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userRemoteDsProvider));
});

// Departments
final departmentRemoteDsProvider = Provider<DepartmentRemoteDataSource>((ref) {
  return DepartmentRemoteDataSource(firestore: ref.watch(firestoreProvider));
});

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  return DepartmentRepositoryImpl(ref.watch(departmentRemoteDsProvider));
});

// Requests
final requestRemoteDsProvider = Provider<RequestRemoteDataSource>((ref) {
  return RequestRemoteDataSource(firestore: ref.watch(firestoreProvider));
});

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepositoryImpl(ref.watch(requestRemoteDsProvider));
});

// Session
final authUidStreamProvider = Provider<Stream<String?>>((ref) {
  return ref.watch(authRepositoryProvider).authUidChanges();
});

final authUidProvider = StreamProvider<String?>((ref) {
  return ref.watch(authUidStreamProvider);
});

final sessionProvider = StreamProvider<AppUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final controller = StreamController<AppUser?>();
  StreamSubscription<String?>? uidSub;
  StreamSubscription<AppUser?>? profileSub;

  uidSub = repo.authUidChanges().listen(
    (uid) {
      profileSub?.cancel();
      if (uid == null) {
        controller.add(null);
        return;
      }
      profileSub = repo.watchUserProfile(uid).listen(
        controller.add,
        onError: controller.addError,
      );
    },
    onError: controller.addError,
  );

  ref.onDispose(() async {
    await profileSub?.cancel();
    await uidSub?.cancel();
    await controller.close();
  });

  return controller.stream;
});

final photoUrlResolverProvider = Provider<PhotoUrlResolver>((ref) {
  return FirebasePhotoUrlResolver();
});

final resolvePhotoUrlUseCaseProvider = Provider<ResolvePhotoUrl>((ref) {
  return ResolvePhotoUrl(ref.watch(photoUrlResolverProvider));
});
