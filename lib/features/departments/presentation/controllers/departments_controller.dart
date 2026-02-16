import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/departments/domain/entities/department.dart';
import 'package:cowork/features/departments/domain/usecases/create_department.dart';
import 'package:cowork/features/departments/domain/usecases/watch_departments.dart';

final watchDepartmentsUseCaseProvider = Provider<WatchDepartments>((ref) {
  return WatchDepartments(ref.watch(departmentRepositoryProvider));
});

final createDepartmentUseCaseProvider = Provider<CreateDepartment>((ref) {
  return CreateDepartment(ref.watch(departmentRepositoryProvider));
});

final departmentsStreamProvider = StreamProvider<List<Department>>((ref) {
  final session = ref.watch(sessionProvider).asData?.value;
  if (session == null) return const Stream.empty();

  final role = switch (session.role) {
    AppRole.admin => 'admin',
    AppRole.manager => 'manager',
    AppRole.employee => 'employee',
  };

  return ref.watch(watchDepartmentsUseCaseProvider).call(
        uid: session.uid,
        role: role,
        departmentId: session.departmentId,
      );
});

final departmentsFormControllerProvider =
    AsyncNotifierProvider<DepartmentsFormController, void>(DepartmentsFormController.new);

class DepartmentsFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> createDepartment({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    if (name.trim().isEmpty) {
      return 'Departman adi gerekli.';
    }

    state = const AsyncLoading();
    try {
      final session = ref.read(sessionProvider).asData?.value;
      if (session == null) {
        state = const AsyncData(null);
        return 'Oturum bilgisi bulunamadi.';
      }

      await ref.read(createDepartmentUseCaseProvider).call(
            name: name.trim(),
            description: description.trim(),
            isActive: isActive,
            createdByUserId: session.uid,
          );
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return 'Departman olusturma hatasi: $e';
    }
  }
}

final departmentsFormFieldsProvider =
    NotifierProvider.autoDispose<DepartmentsFormFieldsController, DepartmentsFormFieldsState>(
        DepartmentsFormFieldsController.new);

class DepartmentsFormFieldsState {
  final bool isActive;

  const DepartmentsFormFieldsState({required this.isActive});

  factory DepartmentsFormFieldsState.initial() {
    return const DepartmentsFormFieldsState(isActive: true);
  }

  DepartmentsFormFieldsState copyWith({bool? isActive}) {
    return DepartmentsFormFieldsState(isActive: isActive ?? this.isActive);
  }
}

class DepartmentsFormFieldsController
    extends Notifier<DepartmentsFormFieldsState> {
  late final TextEditingController name;
  late final TextEditingController description;

  @override
  DepartmentsFormFieldsState build() {
    name = TextEditingController();
    description = TextEditingController();

    ref.onDispose(() {
      name.dispose();
      description.dispose();
    });

    return DepartmentsFormFieldsState.initial();
  }

  void clearForm() {
    name.clear();
    description.clear();
    state = DepartmentsFormFieldsState.initial();
  }

  void setActive(bool value) {
    state = state.copyWith(isActive: value);
  }
}
