import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cowork/features/messages/data/models/chat_message_model.dart';

class MessagesRemoteDataSource {
  final FirebaseFirestore firestore;

  MessagesRemoteDataSource({required this.firestore});

  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String peerUserId,
    required String? departmentId,
  }) async {
    final conversations = await firestore
        .collection('conversations')
        .where('participant_ids', arrayContains: currentUserId)
        .get();

    for (final doc in conversations.docs) {
      final participantIds = (doc.data()['participant_ids'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toSet();
      if (participantIds.contains(peerUserId)) {
        return doc.id;
      }
    }

    final newRef = firestore.collection('conversations').doc();
    final participantIds = <String>[currentUserId, peerUserId]..sort();
    await newRef.set({
      'participant_ids': participantIds,
      'department_id': departmentId,
      'last_message': null,
      'last_message_at': null,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    return newRef.id;
  }

  Stream<List<ChatMessageModel>> watchMessages(String conversationId) {
    return firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ChatMessageModel.fromDoc).toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderUserId,
    required String text,
  }) async {
    final convoRef = firestore.collection('conversations').doc(conversationId);
    final messageRef = convoRef.collection('messages').doc();

    final batch = firestore.batch();
    batch.set(messageRef, {
      'sender_user_id': senderUserId,
      'text': text,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'is_deleted': false,
    });
    batch.update(convoRef, {
      'last_message': text,
      'last_message_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
