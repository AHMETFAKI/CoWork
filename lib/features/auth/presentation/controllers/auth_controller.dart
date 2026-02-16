import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:cowork/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/auth/domain/repositories/auth_repository.dart';
import 'package:cowork/features/users/data/datasources/user_remote_ds.dart';
import 'package:cowork/features/users/data/repositories/user_repository_impl.dart';
import 'package:cowork/features/users/domain/repositories/user_repository.dart';
import 'package:cowork/features/departments/data/datasources/department_remote_ds.dart';
import 'package:cowork/features/departments/data/repositories/department_repository_impl.dart';
import 'package:cowork/features/departments/domain/repositories/department_repository.dart';

// Firebase providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// DataSource & Repo
final authRemoteDsProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDsProvider));
});

// Users data access
final userRemoteDsProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(firestore: ref.watch(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userRemoteDsProvider));
});

// Departments data access
final departmentRemoteDsProvider = Provider<DepartmentRemoteDataSource>((ref) {
  return DepartmentRemoteDataSource(firestore: ref.watch(firestoreProvider));
});

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  return DepartmentRepositoryImpl(ref.watch(departmentRemoteDsProvider));
});

// UID stream + provider
final authUidStreamProvider = Provider<Stream<String?>>((ref) {
  return ref.watch(authRepositoryProvider).authUidChanges();
});

final authUidProvider = StreamProvider<String?>((ref) {
  return ref.watch(authUidStreamProvider);
});

// Firestore AppUser session
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

// AsyncNotifier controller
final authControllerProvider =
AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.watch(authRepositoryProvider);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.signInEmailPassword(email: email, password: password);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.signOut();
    });
  }

  Future<void> createEmployerAccount({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.createEmployerAccount(
        fullName: fullName,
        email: email,
        password: password,
        departmentName: departmentName,
        phone: phone,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
