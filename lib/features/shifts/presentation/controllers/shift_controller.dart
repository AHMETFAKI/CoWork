import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/shifts/domain/entities/shift.dart';
import 'package:cowork/features/shifts/domain/repositories/shift_repository.dart';

final visibleShiftsProvider = StreamProvider<List<ShiftAttendance>>((ref) {
  final user = ref.watch(sessionProvider).asData?.value;
  if (user == null) return const Stream.empty();

  if (user.departmentId == null) return const Stream.empty();

  if (user.role == AppRole.admin) {
    return ref
        .watch(shiftRepositoryProvider)
        .watchAttendanceForDepartment(user.departmentId!);
  }

  if (user.role == AppRole.manager) {
    return ref.watch(shiftRepositoryProvider).watchAttendanceForDepartmentRoles(
      user.departmentId!,
      const ['manager', 'employee'],
    );
  }

  return ref.watch(shiftRepositoryProvider).watchAttendanceForUser(user.uid);
});

final myAttendanceProvider = StreamProvider<List<ShiftAttendance>>((ref) {
  final user = ref.watch(sessionProvider).asData?.value;
  if (user == null) return const Stream.empty();
  return ref.watch(shiftRepositoryProvider).watchAttendanceForUser(user.uid);
});

final shiftControllerProvider =
    AsyncNotifierProvider<ShiftController, void>(ShiftController.new);

class ShiftController extends AsyncNotifier<void> {
  late final ShiftRepository _repo;
  AttendanceEventType? _lastKnownEventType;

  @override
  Future<void> build() async {
    _repo = ref.watch(shiftRepositoryProvider);
  }

  Future<void> createAttendance({
    required AttendanceEventType eventType,
    required AttendanceSource source,
    String? tokenId,
  }) async {
    final user = ref.read(sessionProvider).asData?.value;
    if (user == null) {
      throw StateError('No session user for createAttendance');
    }
    if (user.departmentId == null) {
      throw StateError('Missing departmentId for createAttendance');
    }

    state = const AsyncLoading();
    try {
      final last = await _repo.getLastAttendanceForUser(user.uid);
      final effectiveLastType = _lastKnownEventType ?? last?.eventType;
      if (last != null) {
        _lastKnownEventType = last.eventType;
      }

      if (eventType == AttendanceEventType.checkIn &&
          effectiveLastType == AttendanceEventType.checkIn) {
        throw StateError('Calisma suren zaten basladi. Once check-out yap.');
      }
      if (eventType == AttendanceEventType.checkOut &&
          effectiveLastType != AttendanceEventType.checkIn) {
        throw StateError('Aktif calisma baslangici yok. Once check-in yap.');
      }

      await _repo.createAttendanceEvent(
        departmentId: user.departmentId!,
        userId: user.uid,
        userRole: _roleName(user.role),
        eventType: eventType,
        eventAt: DateTime.now(),
        source: source,
        tokenId: tokenId,
      );
      _lastKnownEventType = eventType;
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> createFromSyntheticLink(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      throw StateError('Invalid synthetic link');
    }

    final action = uri.queryParameters['action'];
    final token = uri.queryParameters['token'];
    final uid = uri.queryParameters['uid'];
    final user = ref.read(sessionProvider).asData?.value;
    if (user == null) throw StateError('No session user for link');
    if (uid != user.uid) {
      throw StateError('Link uid mismatch');
    }

    final eventType = switch (action) {
      'check_out' => AttendanceEventType.checkOut,
      'check_in' => AttendanceEventType.checkIn,
      _ => throw StateError('Invalid link action'),
    };

    await createAttendance(
      eventType: eventType,
      source: AttendanceSource.link,
      tokenId: token,
    );
  }

  String _roleName(AppRole role) {
    return switch (role) {
      AppRole.admin => 'admin',
      AppRole.manager => 'manager',
      AppRole.employee => 'employee',
    };
  }
}
