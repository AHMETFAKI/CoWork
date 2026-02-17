import 'package:cowork/features/shifts/data/datasources/shift_remote_ds.dart';
import 'package:cowork/features/shifts/data/models/shift_model.dart';
import 'package:cowork/features/shifts/domain/entities/shift.dart';
import 'package:cowork/features/shifts/domain/repositories/shift_repository.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftRemoteDataSource remote;

  ShiftRepositoryImpl(this.remote);

  @override
  Stream<List<ShiftAttendance>> watchAttendanceForDepartment(
    String departmentId,
  ) {
    return remote
        .watchAttendanceForDepartment(departmentId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<List<ShiftAttendance>> watchAttendanceForDepartmentRoles(
    String departmentId,
    List<String> roles,
  ) {
    return remote
        .watchAttendanceForDepartmentRoles(departmentId, roles)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<List<ShiftAttendance>> watchAttendanceForUser(String userId) {
    return remote
        .watchAttendanceForUser(userId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<ShiftAttendance?> getLastAttendanceForUser(String userId) async {
    final item = await remote.getLastAttendanceForUser(userId);
    return item?.toEntity();
  }

  @override
  Future<String> createAttendanceEvent({
    required String departmentId,
    required String userId,
    required String userRole,
    required AttendanceEventType eventType,
    required DateTime eventAt,
    required AttendanceSource source,
    String? tokenId,
  }) {
    final model = ShiftModel(
      id: '',
      departmentId: departmentId,
      userId: userId,
      userRole: userRole,
      eventType: switch (eventType) {
        AttendanceEventType.checkIn => 'check_in',
        AttendanceEventType.checkOut => 'check_out',
      },
      eventAt: eventAt,
      source: switch (source) {
        AttendanceSource.manual => 'manual',
        AttendanceSource.link => 'link',
        AttendanceSource.qr => 'qr',
      },
      tokenId: tokenId,
      createdAt: DateTime.now(),
    );
    return remote.createAttendanceEvent(model);
  }
}
