import 'package:cowork/features/departments/domain/entities/department.dart';
import 'package:cowork/features/departments/domain/repositories/department_repository.dart';

class WatchDepartments {
  final DepartmentRepository repository;

  WatchDepartments(this.repository);

  Stream<List<Department>> call({
    required String uid,
    required String role,
    required String? departmentId,
  }) {
    return repository.watchDepartments(
      uid: uid,
      role: role,
      departmentId: departmentId,
    );
  }
}
