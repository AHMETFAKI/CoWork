class ChatMessage {
  final String id;
  final String senderUserId;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderUserId,
    required this.text,
    required this.createdAt,
  });
}
