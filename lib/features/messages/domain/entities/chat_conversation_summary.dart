class ChatConversationSummary {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ChatConversationSummary({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
  });
}
