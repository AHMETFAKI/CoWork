import 'package:cowork/features/departments/domain/entities/department.dart';
import 'package:cowork/features/departments/domain/repositories/department_repository.dart';

class WatchDepartments {
  final DepartmentRepository repository;

  WatchDepartments(this.repository);

  Stream<List<Department>> call() => repository.watchDepartments();
}
