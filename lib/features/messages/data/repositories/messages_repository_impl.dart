import 'package:cowork/features/messages/data/datasources/messages_remote_ds.dart';
import 'package:cowork/features/messages/domain/entities/chat_conversation_summary.dart';
import 'package:cowork/features/messages/domain/entities/chat_message.dart';
import 'package:cowork/features/messages/domain/repositories/messages_repository.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesRemoteDataSource remote;

  MessagesRepositoryImpl(this.remote);

  @override
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String peerUserId,
    required String? departmentId,
  }) {
    return remote.getOrCreateConversation(
      currentUserId: currentUserId,
      peerUserId: peerUserId,
      departmentId: departmentId,
    );
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return remote
        .watchMessages(conversationId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<List<ChatConversationSummary>> watchConversations(String currentUserId) {
    return remote
        .watchConversations(currentUserId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderUserId,
    required String text,
  }) {
    return remote.sendMessage(
      conversationId: conversationId,
      senderUserId: senderUserId,
      text: text,
    );
  }
}
