import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cowork/features/messages/domain/entities/chat_message.dart';

class ChatMessageModel {
  final String id;
  final String senderUserId;
  final String text;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.senderUserId,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw StateError('Message doc missing data: ${doc.id}');
    final createdAt = data['created_at'];
    return ChatMessageModel(
      id: doc.id,
      senderUserId: (data['sender_user_id'] ?? '') as String,
      text: (data['text'] ?? '') as String,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      senderUserId: senderUserId,
      text: text,
      createdAt: createdAt,
    );
  }
}
