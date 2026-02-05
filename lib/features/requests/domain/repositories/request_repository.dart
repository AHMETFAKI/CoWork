import '../entities/request.dart';

abstract class RequestRepository {
  Stream<List<Request>> watchRequestsForUser(String uid);
  Stream<List<Request>> watchRequestsForDepartment(String departmentId);
  Future<String> createRequest({
    required String createdByUserId,
    required String departmentId,
    required RequestType type,
    required String reason,
    double? amount,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  });
  Future<void> updateStatus({
    required String requestId,
    required RequestStatus status,
    required String reviewerUserId,
    String? comment,
  });
}
