import '../../domain/entities/app_user.dart';

class AppUserModel {
  final String uid;
  final String name;
  final String role; // "admin" | "manager" | "employee"
  final String? departmentId;

  AppUserModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.departmentId,
  });

  factory AppUserModel.fromMap(String uid, Map<String, dynamic> map) {
    return AppUserModel(
      uid: uid,
      name: (map['full_name'] ?? '') as String,
      role: (map['role'] ?? 'employee') as String,
      departmentId: map['department_id'] as String?,
    );
  }

  AppUser toEntity() {
    final parsedRole = switch (role) {
      'admin' => AppRole.admin,
      'manager' => AppRole.manager,
      _ => AppRole.employee,
    };

    return AppUser(
      uid: uid,
      name: name,
      role: parsedRole,
      departmentId: departmentId,
    );
  }
}
