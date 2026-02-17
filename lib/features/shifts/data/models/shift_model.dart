import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cowork/features/shifts/domain/entities/shift.dart';

class ShiftModel {
  final String id;
  final String departmentId;
  final String userId;
  final String userRole;
  final String eventType;
  final DateTime eventAt;
  final String source;
  final String? tokenId;
  final DateTime createdAt;

  ShiftModel({
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

  factory ShiftModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Shift doc missing data: ${doc.id}');
    }

    final eventAt = data['event_at'];
    final createdAt = data['created_at'];

    return ShiftModel(
      id: doc.id,
      departmentId: (data['department_id'] ?? '') as String,
      userId: (data['user_id'] ?? '') as String,
      userRole: (data['user_role'] ?? '') as String,
      eventType: (data['event_type'] ?? 'check_in') as String,
      eventAt: eventAt is Timestamp
          ? eventAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      source: (data['source'] ?? 'manual') as String,
      tokenId: data['token_id'] as String?,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'department_id': departmentId,
      'user_id': userId,
      'user_role': userRole,
      'event_type': eventType,
      'event_at': Timestamp.fromDate(eventAt),
      'source': source,
      'token_id': tokenId,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  ShiftAttendance toEntity() {
    return ShiftAttendance(
      id: id,
      departmentId: departmentId,
      userId: userId,
      userRole: userRole,
      eventType: _parseEventType(eventType),
      eventAt: eventAt,
      source: _parseSource(source),
      tokenId: tokenId,
      createdAt: createdAt,
    );
  }

  static AttendanceEventType _parseEventType(String value) {
    return switch (value) {
      'check_out' => AttendanceEventType.checkOut,
      _ => AttendanceEventType.checkIn,
    };
  }

  static AttendanceSource _parseSource(String value) {
    return switch (value) {
      'link' => AttendanceSource.link,
      'qr' => AttendanceSource.qr,
      _ => AttendanceSource.manual,
    };
  }
}
