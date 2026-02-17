import 'package:cowork/features/messages/domain/entities/chat_message.dart';

abstract class MessagesRepository {
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String peerUserId,
    required String? departmentId,
  });

  Stream<List<ChatMessage>> watchMessages(String conversationId);

  Future<void> sendMessage({
    required String conversationId,
    required String senderUserId,
    required String text,
  });
}
