class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? departmentId;
  final String? managerId;
  final String? phone;
  final bool isActive;
  final String? createdByUserId;

  const UserProfile({
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
}
