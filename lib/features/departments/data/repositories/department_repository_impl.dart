import '../../domain/entities/department.dart';
import '../../domain/repositories/department_repository.dart';
import '../datasources/department_remote_ds.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentRemoteDataSource remote;

  DepartmentRepositoryImpl(this.remote);

  @override
  Stream<List<Department>> watchDepartments() {
    return remote
        .watchDepartments()
        .map((items) => items.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> createDepartment({
    required String name,
    required String description,
    required bool isActive,
  }) {
    return remote.createDepartment(
      name: name,
      description: description,
      isActive: isActive,
    );
  }
}
