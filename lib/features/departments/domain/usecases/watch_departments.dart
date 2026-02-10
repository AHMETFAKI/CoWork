import '../entities/department.dart';
import '../repositories/department_repository.dart';

class WatchDepartments {
  final DepartmentRepository repository;

  WatchDepartments(this.repository);

  Stream<List<Department>> call() => repository.watchDepartments();
}
