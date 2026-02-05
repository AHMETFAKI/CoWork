import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/request.dart';

class RequestModel {
  final String id;
  final String createdByUserId;
  final String departmentId;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String reason;
  final double? amount;
  final String? currency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;

  RequestModel({
    required this.id,
    required this.createdByUserId,
    required this.departmentId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.reason,
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.category,
  });

  factory RequestModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Request doc missing data: ${doc.id}');
    }
    final createdAt = data['created_at'];
    final updatedAt = data['updated_at'];
    final startDate = data['start_date'];
    final endDate = data['end_date'];
    return RequestModel(
      id: doc.id,
      createdByUserId: (data['created_by_user_id'] ?? '') as String,
      departmentId: (data['department_id'] ?? '') as String,
      type: (data['type'] ?? 'leave') as String,
      status: (data['status'] ?? 'pending') as String,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
      reason: (data['reason'] ?? '') as String,
      amount: (data['amount'] as num?)?.toDouble(),
      currency: data['currency'] as String?,
      startDate: startDate is Timestamp ? startDate.toDate() : null,
      endDate: endDate is Timestamp ? endDate.toDate() : null,
      category: data['category'] as String?,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'created_by_user_id': createdByUserId,
      'department_id': departmentId,
      'type': type,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'reason': reason,
      'amount': amount,
      'currency': currency,
      'start_date': startDate == null ? null : Timestamp.fromDate(startDate!),
      'end_date': endDate == null ? null : Timestamp.fromDate(endDate!),
      'category': category,
    };
  }

  Request toEntity() {
    return Request(
      id: id,
      createdByUserId: createdByUserId,
      departmentId: departmentId,
      type: _parseType(type),
      status: _parseStatus(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
      reason: reason,
      amount: amount,
      currency: currency,
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
  }

  static RequestType _parseType(String value) {
    return switch (value) {
      'leave' => RequestType.leave,
      'advance' => RequestType.advance,
      'expense' => RequestType.expense,
      _ => RequestType.leave,
    };
  }

  static RequestStatus _parseStatus(String value) {
    return switch (value) {
      'approved' => RequestStatus.approved,
      'rejected' => RequestStatus.rejected,
      'cancelled' => RequestStatus.cancelled,
      _ => RequestStatus.pending,
    };
  }
}
