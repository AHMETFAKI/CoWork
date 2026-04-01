import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/departments/domain/entities/department.dart';
import 'package:cowork/features/departments/domain/repositories/department_repository.dart';
import 'package:cowork/features/departments/presentation/controllers/departments_controller.dart';
import 'package:cowork/features/users/domain/entities/save_user_result.dart';
import 'package:cowork/features/users/domain/entities/user_profile.dart';
import 'package:cowork/features/users/domain/repositories/user_repository.dart';
import 'package:cowork/features/users/presentation/controllers/users_controller.dart';

void main() {
  group('Directory Providers', () {
    test('usersDirectoryStreamProvider reads directory users', () async {
      final fakeUserRepo = _FakeUserRepository()
        ..directoryUsers = const [
          UserProfile(
            id: 'u1',
            fullName: 'Alice',
            email: 'alice@example.com',
            role: 'manager',
            departmentId: 'dept-1',
            managerId: null,
            phone: null,
            isActive: true,
            createdByUserId: 'admin-1',
            photoUrl: null,
          ),
        ];

      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeUserRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'employee-1',
                name: 'Employee',
                role: AppRole.employee,
                departmentId: 'dept-1',
                createdByUserId: 'admin-1',
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sessionProvider.future);
      final items = await container.read(usersDirectoryStreamProvider.future);
      expect(fakeUserRepo.lastDirectoryUid, 'employee-1');
      expect(fakeUserRepo.lastDirectoryCreatedBy, 'admin-1');
      expect(items.length, 1);
      expect(items.first.fullName, 'Alice');
    });

    test('departmentsDirectoryStreamProvider reads directory departments', () async {
      final fakeDepartmentRepo = _FakeDepartmentRepository()
        ..directoryDepartments = const [
          Department(
            id: 'dept-1',
            name: 'Engineering',
            description: '',
            managerId: 'u1',
            isActive: true,
          ),
        ];

      final container = ProviderContainer(
        overrides: [
          departmentRepositoryProvider.overrideWithValue(fakeDepartmentRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'employee-1',
                name: 'Employee',
                role: AppRole.employee,
                departmentId: 'dept-1',
                createdByUserId: 'admin-1',
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sessionProvider.future);
      final items = await container.read(departmentsDirectoryStreamProvider.future);
      expect(fakeDepartmentRepo.lastDirectoryUid, 'employee-1');
      expect(fakeDepartmentRepo.lastDirectoryCreatedBy, 'admin-1');
      expect(items.length, 1);
      expect(items.first.name, 'Engineering');
    });
  });
}

class _FakeUserRepository implements UserRepository {
  String? lastDirectoryUid;
  String? lastDirectoryCreatedBy;
  List<UserProfile> directoryUsers = const [];

  @override
  Stream<List<UserProfile>> watchUsersForDirectory({
    required String uid,
    required String? createdByUserId,
  }) {
    lastDirectoryUid = uid;
    lastDirectoryCreatedBy = createdByUserId;
    return Stream.value(directoryUsers);
  }

  @override
  Stream<List<UserProfile>> watchUsersForSession({
    required String uid,
    required String role,
    required String? departmentId,
    required String? createdByUserId,
  }) {
    return const Stream.empty();
  }

  @override
  Future<UserProfile?> getUserById(String uid) async {
    return null;
  }

  @override
  Future<UserProfile?> getUserByEmail(String email) async {
    return null;
  }

  @override
  Future<SaveUserResult> saveUser({
    required String actorUid,
    required String docId,
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String? departmentId,
    required String? selectedDeptManagerId,
    required String phone,
    required bool isActive,
    required bool setDeptManager,
    required Uint8List? photoBytes,
  }) async {
    return const SaveUserResult.success();
  }
}

class _FakeDepartmentRepository implements DepartmentRepository {
  String? lastDirectoryUid;
  String? lastDirectoryCreatedBy;
  List<Department> directoryDepartments = const [];

  @override
  Stream<List<Department>> watchDepartments({
    required String uid,
    required String role,
    required String? departmentId,
  }) {
    return const Stream.empty();
  }

  @override
  Stream<List<Department>> watchDepartmentsForDirectory({
    required String uid,
    required String? createdByUserId,
  }) {
    lastDirectoryUid = uid;
    lastDirectoryCreatedBy = createdByUserId;
    return Stream.value(directoryDepartments);
  }

  @override
  Future<void> createDepartment({
    required String name,
    required String description,
    required bool isActive,
    required String createdByUserId,
  }) async {}
}
