import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/messages/domain/entities/chat_message.dart';
import 'package:cowork/features/messages/domain/repositories/messages_repository.dart';

final conversationIdProvider = FutureProvider.family<String, String>((ref, peerUid) async {
  final user = ref.watch(sessionProvider).asData?.value;
  if (user == null) throw StateError('No session user for conversation');
  final repo = ref.watch(messagesRepositoryProvider);
  return repo.getOrCreateConversation(
    currentUserId: user.uid,
    peerUserId: peerUid,
    departmentId: user.departmentId,
  );
});

final messagesStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
      return ref.watch(messagesRepositoryProvider).watchMessages(conversationId);
    });

final messagesControllerProvider =
    AsyncNotifierProvider<MessagesController, void>(MessagesController.new);

class MessagesController extends AsyncNotifier<void> {
  late final MessagesRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.watch(messagesRepositoryProvider);
  }

  Future<void> sendMessage({
    required String peerUid,
    required String text,
  }) async {
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null) throw StateError('No session user for sendMessage');
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw StateError('Message cannot be empty');

    state = const AsyncLoading();
    try {
      final conversationId = await _repo.getOrCreateConversation(
        currentUserId: session.uid,
        peerUserId: peerUid,
        departmentId: session.departmentId,
      );
      await _repo.sendMessage(
        conversationId: conversationId,
        senderUserId: session.uid,
        text: trimmed,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
