enum RequestStatus { pending, approved, rejected, cancelled }

enum RequestType { leave, advance, expense }

class Request {
  final String id;
  final String createdByUserId;
  final String departmentId;
  final RequestType type;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String reason;
  final double? amount;
  final String? currency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;

  const Request({
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
}
