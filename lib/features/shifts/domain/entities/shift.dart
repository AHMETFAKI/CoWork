enum AttendanceEventType { checkIn, checkOut }

enum AttendanceSource { manual, link, qr }

class ShiftAttendance {
  final String id;
  final String departmentId;
  final String userId;
  final String userRole;
  final AttendanceEventType eventType;
  final DateTime eventAt;
  final AttendanceSource source;
  final String? tokenId;
  final DateTime createdAt;

  const ShiftAttendance({
    required this.id,
    required this.departmentId,
    required this.userId,
    required this.userRole,
    required this.eventType,
    required this.eventAt,
    required this.source,
    required this.tokenId,
    required this.createdAt,
  });
}
