import 'package:cowork/features/departments/domain/entities/department.dart';
import 'package:cowork/features/departments/domain/repositories/department_repository.dart';
import 'package:cowork/features/departments/data/datasources/department_remote_ds.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentRemoteDataSource remote;

  DepartmentRepositoryImpl(this.remote);

  @override
  Stream<List<Department>> watchDepartments({
    required String uid,
    required String role,
    required String? departmentId,
  }) {
    return remote
        .watchDepartments(
          uid: uid,
          role: role,
          departmentId: departmentId,
        )
        .map((items) => items.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<Department>> watchDepartmentsForDirectory({
    required String uid,
    required String? createdByUserId,
  }) {
    return remote
        .watchDepartmentsForDirectory(
          uid: uid,
          createdByUserId: createdByUserId,
        )
        .map((items) => items.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> createDepartment({
    required String name,
    required String description,
    required bool isActive,
    required String createdByUserId,
  }) {
    return remote.createDepartment(
      name: name,
      description: description,
      isActive: isActive,
      createdByUserId: createdByUserId,
    );
  }
}
