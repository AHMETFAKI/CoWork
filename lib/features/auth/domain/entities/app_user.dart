enum AppRole { admin, manager, employee }

class AppUser {
  final String uid;
  final String name;
  final AppRole role;
  final String? departmentId;
  final String? createdByUserId;

  const AppUser({
    required this.uid,
    required this.name,
    required this.role,
    required this.departmentId,
    required this.createdByUserId,
  });
}
