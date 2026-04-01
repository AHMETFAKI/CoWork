import 'package:cowork/features/departments/domain/entities/department.dart';

abstract class DepartmentRepository {
  Stream<List<Department>> watchDepartments({
    required String uid,
    required String role,
    required String? departmentId,
  });

  Stream<List<Department>> watchDepartmentsForDirectory({
    required String uid,
    required String? createdByUserId,
  });

  Future<void> createDepartment({
    required String name,
    required String description,
    required bool isActive,
    required String createdByUserId,
  });
}
