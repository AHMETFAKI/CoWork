import '../entities/department.dart';

abstract class DepartmentRepository {
  Stream<List<Department>> watchDepartments();

  Future<void> createDepartment({
    required String name,
    required String description,
    required bool isActive,
  });
}
