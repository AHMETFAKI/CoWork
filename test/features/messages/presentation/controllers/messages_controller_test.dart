import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/messages/domain/entities/chat_conversation_summary.dart';
import 'package:cowork/features/messages/domain/entities/chat_message.dart';
import 'package:cowork/features/messages/domain/repositories/messages_repository.dart';
import 'package:cowork/features/messages/presentation/controllers/messages_controller.dart';

void main() {
  group('MessagesController', () {
    test('sendMessage trims text and calls repository with session values', () async {
      final fakeRepo = _FakeMessagesRepository();
      final container = ProviderContainer(
        overrides: [
          messagesRepositoryProvider.overrideWithValue(fakeRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'user-1',
                name: 'User',
                role: AppRole.employee,
                departmentId: 'dept-1',
                createdByUserId: 'admin-1',
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sessionProvider.future);
      await container.read(messagesControllerProvider.future);
      await container.read(messagesControllerProvider.notifier).sendMessage(
            peerUid: 'user-2',
            text: '  hello world  ',
          );

      expect(fakeRepo.lastGetOrCreateCurrentUserId, 'user-1');
      expect(fakeRepo.lastGetOrCreatePeerUserId, 'user-2');
      expect(fakeRepo.lastGetOrCreateDepartmentId, 'dept-1');
      expect(fakeRepo.lastSendConversationId, 'conversation-1');
      expect(fakeRepo.lastSendSenderUserId, 'user-1');
      expect(fakeRepo.lastSendText, 'hello world');
    });

    test('sendMessage throws for empty text', () async {
      final fakeRepo = _FakeMessagesRepository();
      final container = ProviderContainer(
        overrides: [
          messagesRepositoryProvider.overrideWithValue(fakeRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'user-1',
                name: 'User',
                role: AppRole.employee,
                departmentId: 'dept-1',
                createdByUserId: 'admin-1',
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sessionProvider.future);
      await container.read(messagesControllerProvider.future);
      await expectLater(
        container.read(messagesControllerProvider.notifier).sendMessage(
              peerUid: 'user-2',
              text: '   ',
            ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Messages Providers', () {
    test('conversationsStreamProvider uses session uid', () async {
      final fakeRepo = _FakeMessagesRepository();
      fakeRepo.conversations = [
        ChatConversationSummary(
          id: 'conversation-1',
          participantIds: const ['user-1', 'user-2'],
          lastMessage: 'hi',
          lastMessageAt: DateTime(2026, 2, 18, 12, 0),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          messagesRepositoryProvider.overrideWithValue(fakeRepo),
          sessionProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: 'user-1',
                name: 'User',
                role: AppRole.employee,
                departmentId: 'dept-1',
                createdByUserId: 'admin-1',
                photoUrl: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sessionProvider.future);
      final items = await container.read(conversationsStreamProvider.future);
      expect(fakeRepo.lastWatchConversationsUserId, 'user-1');
      expect(items.length, 1);
      expect(items.first.id, 'conversation-1');
    });
  });
}

class _FakeMessagesRepository implements MessagesRepository {
  String? lastGetOrCreateCurrentUserId;
  String? lastGetOrCreatePeerUserId;
  String? lastGetOrCreateDepartmentId;
  String? lastSendConversationId;
  String? lastSendSenderUserId;
  String? lastSendText;
  String? lastWatchConversationsUserId;
  List<ChatConversationSummary> conversations = const [];

  @override
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String peerUserId,
    required String? departmentId,
  }) async {
    lastGetOrCreateCurrentUserId = currentUserId;
    lastGetOrCreatePeerUserId = peerUserId;
    lastGetOrCreateDepartmentId = departmentId;
    return 'conversation-1';
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderUserId,
    required String text,
  }) async {
    lastSendConversationId = conversationId;
    lastSendSenderUserId = senderUserId;
    lastSendText = text;
  }

  @override
  Stream<List<ChatConversationSummary>> watchConversations(String currentUserId) {
    lastWatchConversationsUserId = currentUserId;
    return Stream.value(conversations);
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return const Stream.empty();
  }
}
