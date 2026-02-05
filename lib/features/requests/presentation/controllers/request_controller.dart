import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/request_remote_ds.dart';
import '../../data/repositories/request_repository_impl.dart';
import '../../domain/entities/request.dart';
import '../../domain/repositories/request_repository.dart';

final requestRemoteDsProvider = Provider<RequestRemoteDataSource>((ref) {
  return RequestRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
  );
});

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepositoryImpl(ref.watch(requestRemoteDsProvider));
});

final myRequestsProvider = StreamProvider<List<Request>>((ref) {
  final user = ref.watch(sessionProvider).asData?.value;
  if (user == null) return const Stream.empty();
  return ref.watch(requestRepositoryProvider).watchRequestsForUser(user.uid);
});

final departmentRequestsProvider = StreamProvider<List<Request>>((ref) {
  final user = ref.watch(sessionProvider).asData?.value;
  if (user == null) return const Stream.empty();
  final departmentId = user.departmentId;
  if (departmentId == null) return const Stream.empty();
  return ref
      .watch(requestRepositoryProvider)
      .watchRequestsForDepartment(departmentId);
});

final requestControllerProvider =
    AsyncNotifierProvider<RequestController, void>(RequestController.new);

class RequestController extends AsyncNotifier<void> {
  late final RequestRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.watch(requestRepositoryProvider);
  }

  Future<void> createRequest({
    required RequestType type,
    required String reason,
    double? amount,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    final user = ref.read(sessionProvider).asData?.value;
    if (user == null) {
      throw StateError('No session user for createRequest');
    }
    if (user.departmentId == null) {
      throw StateError('Missing departmentId for createRequest');
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.createRequest(
        createdByUserId: user.uid,
        departmentId: user.departmentId!,
        type: type,
        reason: reason,
        amount: amount,
        currency: currency,
        startDate: startDate,
        endDate: endDate,
        category: category,
      );
    });
  }

  Future<void> updateStatus({
    required String requestId,
    required RequestStatus status,
    String? comment,
  }) async {
    final user = ref.read(sessionProvider).asData?.value;
    if (user == null) {
      throw StateError('No session user for updateStatus');
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.updateStatus(
        requestId: requestId,
        status: status,
        reviewerUserId: user.uid,
        comment: comment,
      );
    });
  }
}
