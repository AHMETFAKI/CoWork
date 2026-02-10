import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? departmentId;
  final String? managerId;
  final String? phone;
  final bool isActive;
  final String? createdByUserId;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.departmentId,
    required this.managerId,
    required this.phone,
    required this.isActive,
    required this.createdByUserId,
  });

  factory UserProfileModel.fromMap(String id, Map<String, dynamic> map) {
    return UserProfileModel(
      id: id,
      fullName: (map['full_name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      role: (map['role'] ?? 'employee') as String,
      departmentId: map['department_id'] as String?,
      managerId: map['manager_id'] as String?,
      phone: map['phone'] as String?,
      isActive: (map['is_active'] ?? true) as bool,
      createdByUserId: map['created_by_user_id'] as String?,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      departmentId: departmentId,
      managerId: managerId,
      phone: phone,
      isActive: isActive,
      createdByUserId: createdByUserId,
    );
  }
}
