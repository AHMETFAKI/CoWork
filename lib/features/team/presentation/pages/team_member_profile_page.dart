import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/messages/presentation/controllers/messages_controller.dart';
import 'package:cowork/features/users/domain/entities/user_profile.dart';
import 'package:cowork/features/users/presentation/controllers/users_controller.dart';
import 'package:cowork/shared/ui/feedback/app_feedback.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';
import 'package:cowork/shared/widgets/async_elevated_button.dart';
import 'package:cowork/shared/widgets/resolved_avatar.dart';

class TeamMemberProfilePage extends ConsumerStatefulWidget {
  const TeamMemberProfilePage({
    super.key,
    required this.memberUid,
  });

  final String memberUid;

  @override
  ConsumerState<TeamMemberProfilePage> createState() => _TeamMemberProfilePageState();
}

class _TeamMemberProfilePageState extends ConsumerState<TeamMemberProfilePage> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersStreamProvider);
    final convoIdAsync = ref.watch(conversationIdProvider(widget.memberUid));
    final messageState = ref.watch(messagesControllerProvider);
    final session = ref.watch(sessionProvider).asData?.value;

    return AppScaffold(
      title: 'Profil',
      child: users.when(
        data: (list) {
          UserProfile? member;
          for (final item in list) {
            if (item.id == widget.memberUid) {
              member = item;
              break;
            }
          }

          if (member == null) {
            return const Center(child: Text('Kullanici bulunamadi.'));
          }

          return Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: ResolvedAvatar(
                  photoUrl: member.photoUrl,
                  radius: 44,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  fallback: const Icon(Icons.person_outline, size: 30),
                ),
              ),
              const SizedBox(height: 10),
              Text(member.fullName, style: Theme.of(context).textTheme.titleLarge),
              Text(member.role),
              const SizedBox(height: 14),
              Expanded(
                child: convoIdAsync.when(
                  data: (conversationId) {
                    final messages = ref.watch(messagesStreamProvider(conversationId));
                    return messages.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const Center(child: Text('Henüz mesaj yok.'));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final mine = session != null && item.senderUserId == session.uid;
                            return Align(
                              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                constraints: const BoxConstraints(maxWidth: 280),
                                decoration: BoxDecoration(
                                  color: mine
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(item.text),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _message,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Mesaj yaz...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AsyncElevatedButton(
                        loading: messageState.isLoading,
                        onPressed: () => _sendMessage(context),
                        child: const Text('Gonder'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _sendMessage(BuildContext context) async {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    try {
      await ref.read(messagesControllerProvider.notifier).sendMessage(
            peerUid: widget.memberUid,
            text: text,
          );
      _message.clear();
    } catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, 'Mesaj gonderilemedi: $e');
    }
  }
}
