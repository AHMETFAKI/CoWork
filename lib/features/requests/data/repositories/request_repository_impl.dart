import '../../domain/entities/request.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/request_remote_ds.dart';
import '../models/request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remote;

  RequestRepositoryImpl(this.remote);

  @override
  Stream<List<Request>> watchRequestsForUser(String uid) {
    return remote
        .watchRequestsForUser(uid)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<List<Request>> watchRequestsForDepartment(String departmentId) {
    return remote
        .watchRequestsForDepartment(departmentId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
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
  }) {
    final model = RequestModel(
      id: '',
      createdByUserId: createdByUserId,
      departmentId: departmentId,
      type: type.name,
      status: RequestStatus.pending.name,
      createdAt: DateTime.now(),
      updatedAt: null,
      reason: reason,
      amount: amount,
      currency: currency,
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
    return remote.createRequest(model);
  }

  @override
  Future<void> updateStatus({
    required String requestId,
    required RequestStatus status,
    required String reviewerUserId,
    String? comment,
  }) {
    return remote.updateStatus(
      requestId: requestId,
      status: status.name,
      reviewerUserId: reviewerUserId,
      comment: comment,
    );
  }
}
