import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cowork/features/messages/domain/entities/chat_conversation_summary.dart';

class ChatConversationSummaryModel {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ChatConversationSummaryModel({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  factory ChatConversationSummaryModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return ChatConversationSummaryModel(
      id: doc.id,
      participantIds: (data['participant_ids'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      lastMessage: data['last_message'] as String?,
      lastMessageAt: _toDateTime(data['last_message_at']),
    );
  }

  ChatConversationSummary toEntity() {
    return ChatConversationSummary(
      id: id,
      participantIds: participantIds,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
