import 'package:cowork/features/shifts/domain/entities/shift.dart';

abstract class ShiftRepository {
  Stream<List<ShiftAttendance>> watchAttendanceForDepartment(String departmentId);

  Stream<List<ShiftAttendance>> watchAttendanceForDepartmentRoles(
    String departmentId,
    List<String> roles,
  );

  Stream<List<ShiftAttendance>> watchAttendanceForUser(String userId);

  Future<ShiftAttendance?> getLastAttendanceForUser(String userId);

  Future<String> createAttendanceEvent({
    required String departmentId,
    required String userId,
    required String userRole,
    required AttendanceEventType eventType,
    required DateTime eventAt,
    required AttendanceSource source,
    String? tokenId,
  });
}
