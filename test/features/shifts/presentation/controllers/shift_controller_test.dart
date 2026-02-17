import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/shifts/domain/entities/shift.dart';
import 'package:cowork/features/shifts/domain/repositories/shift_repository.dart';
import 'package:cowork/features/shifts/presentation/controllers/shift_controller.dart';

void main() {
  group('ShiftController', () {
    test('createAttendance calls repository with session values', () async {
      final fakeRepo = _FakeShiftRepository();
      final container = ProviderContainer(
        overrides: [
          shiftRepositoryProvider.overrideWithValue(fakeRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'manager-1',
                name: 'Manager',
                role: AppRole.manager,
                departmentId: 'dept-1',
                createdByUserId: null,
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(shiftControllerProvider.future);
      await container.read(shiftControllerProvider.notifier).createAttendance(
        eventType: AttendanceEventType.checkIn,
        source: AttendanceSource.link,
        tokenId: 'tok-1',
      );

      expect(fakeRepo.lastDepartmentId, 'dept-1');
      expect(fakeRepo.lastUserId, 'manager-1');
      expect(fakeRepo.lastUserRole, 'manager');
      expect(fakeRepo.lastEventType, AttendanceEventType.checkIn);
      expect(fakeRepo.lastSource, AttendanceSource.link);
      expect(fakeRepo.lastTokenId, 'tok-1');
    });

    test('createAttendance blocks check-in when already checked-in', () async {
      final fakeRepo = _FakeShiftRepository()
        ..lastAttendanceForUser = ShiftAttendance(
          id: 'a1',
          departmentId: 'dept-1',
          userId: 'manager-1',
          userRole: 'manager',
          eventType: AttendanceEventType.checkIn,
          eventAt: DateTime(2026, 1, 1, 9, 0),
          source: AttendanceSource.manual,
          tokenId: null,
          createdAt: DateTime(2026, 1, 1, 9, 0),
        );
      final container = ProviderContainer(
        overrides: [
          shiftRepositoryProvider.overrideWithValue(fakeRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'manager-1',
                name: 'Manager',
                role: AppRole.manager,
                departmentId: 'dept-1',
                createdByUserId: null,
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(shiftControllerProvider.future);
      await expectLater(
        container.read(shiftControllerProvider.notifier).createAttendance(
          eventType: AttendanceEventType.checkIn,
          source: AttendanceSource.link,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('createAttendance blocks check-out without active check-in', () async {
      final fakeRepo = _FakeShiftRepository()
        ..lastAttendanceForUser = ShiftAttendance(
          id: 'a2',
          departmentId: 'dept-1',
          userId: 'manager-1',
          userRole: 'manager',
          eventType: AttendanceEventType.checkOut,
          eventAt: DateTime(2026, 1, 1, 18, 0),
          source: AttendanceSource.manual,
          tokenId: null,
          createdAt: DateTime(2026, 1, 1, 18, 0),
        );
      final container = ProviderContainer(
        overrides: [
          shiftRepositoryProvider.overrideWithValue(fakeRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'manager-1',
                name: 'Manager',
                role: AppRole.manager,
                departmentId: 'dept-1',
                createdByUserId: null,
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(shiftControllerProvider.future);
      await expectLater(
        container.read(shiftControllerProvider.notifier).createAttendance(
          eventType: AttendanceEventType.checkOut,
          source: AttendanceSource.link,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('createAttendance throws if session has no department', () async {
      final fakeRepo = _FakeShiftRepository();
      final container = ProviderContainer(
        overrides: [
          shiftRepositoryProvider.overrideWithValue(fakeRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'admin-1',
                name: 'Admin',
                role: AppRole.admin,
                departmentId: null,
                createdByUserId: null,
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(shiftControllerProvider.future);
      await expectLater(
        container.read(shiftControllerProvider.notifier).createAttendance(
          eventType: AttendanceEventType.checkOut,
          source: AttendanceSource.link,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}

class _FakeShiftRepository implements ShiftRepository {
  String? lastDepartmentId;
  String? lastUserId;
  String? lastUserRole;
  AttendanceEventType? lastEventType;
  AttendanceSource? lastSource;
  String? lastTokenId;
  ShiftAttendance? lastAttendanceForUser;

  @override
  Future<String> createAttendanceEvent({
    required String departmentId,
    required String userId,
    required String userRole,
    required AttendanceEventType eventType,
    required DateTime eventAt,
    required AttendanceSource source,
    String? tokenId,
  }) async {
    lastDepartmentId = departmentId;
    lastUserId = userId;
    lastUserRole = userRole;
    lastEventType = eventType;
    lastSource = source;
    lastTokenId = tokenId;
    return 'shift-1';
  }

  @override
  Stream<List<ShiftAttendance>> watchAttendanceForDepartment(String departmentId) {
    return const Stream.empty();
  }

  @override
  Stream<List<ShiftAttendance>> watchAttendanceForDepartmentRoles(
    String departmentId,
    List<String> roles,
  ) {
    return const Stream.empty();
  }

  @override
  Stream<List<ShiftAttendance>> watchAttendanceForUser(String userId) {
    return const Stream.empty();
  }

  @override
  Future<ShiftAttendance?> getLastAttendanceForUser(String userId) async {
    return lastAttendanceForUser;
  }
}
