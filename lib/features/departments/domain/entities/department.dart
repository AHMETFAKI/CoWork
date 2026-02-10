class Department {
  final String id;
  final String name;
  final String description;
  final String? managerId;
  final bool isActive;

  const Department({
    required this.id,
    required this.name,
    required this.description,
    required this.managerId,
    required this.isActive,
  });
}
