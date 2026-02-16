import 'package:cowork/features/departments/domain/repositories/department_repository.dart';

class CreateDepartment {
  final DepartmentRepository repository;

  CreateDepartment(this.repository);

  Future<void> call({
    required String name,
    required String description,
    required bool isActive,
    required String createdByUserId,
  }) {
    return repository.createDepartment(
      name: name,
      description: description,
      isActive: isActive,
      createdByUserId: createdByUserId,
    );
  }
}
