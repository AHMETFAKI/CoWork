import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/department.dart';
import '../../domain/usecases/create_department.dart';
import '../../domain/usecases/watch_departments.dart';

final watchDepartmentsUseCaseProvider = Provider<WatchDepartments>((ref) {
  return WatchDepartments(ref.watch(departmentRepositoryProvider));
});

final createDepartmentUseCaseProvider = Provider<CreateDepartment>((ref) {
  return CreateDepartment(ref.watch(departmentRepositoryProvider));
});

final departmentsStreamProvider = StreamProvider<List<Department>>((ref) {
  return ref.watch(watchDepartmentsUseCaseProvider).call();
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
      await ref.read(createDepartmentUseCaseProvider).call(
            name: name.trim(),
            description: description.trim(),
            isActive: isActive,
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
    AutoDisposeNotifierProvider<DepartmentsFormFieldsController, DepartmentsFormFieldsState>(
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
    extends AutoDisposeNotifier<DepartmentsFormFieldsState> {
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
