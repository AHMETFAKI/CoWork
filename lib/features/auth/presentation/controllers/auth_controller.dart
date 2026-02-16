import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/domain/repositories/auth_repository.dart';

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
    Uint8List? photoBytes,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.createEmployerAccount(
        fullName: fullName,
        email: email,
        password: password,
        departmentName: departmentName,
        phone: phone,
        photoBytes: photoBytes,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
