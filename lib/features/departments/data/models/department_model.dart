import '../../domain/entities/department.dart';

class DepartmentModel {
  final String id;
  final String name;
  final String description;
  final String? managerId;
  final bool isActive;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.managerId,
    required this.isActive,
  });

  factory DepartmentModel.fromMap(String id, Map<String, dynamic> map) {
    return DepartmentModel(
      id: id,
      name: (map['name'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      managerId: map['manager_id'] as String?,
      isActive: (map['is_active'] ?? true) as bool,
    );
  }

  Department toEntity() {
    return Department(
      id: id,
      name: name,
      description: description,
      managerId: managerId,
      isActive: isActive,
    );
  }
}
