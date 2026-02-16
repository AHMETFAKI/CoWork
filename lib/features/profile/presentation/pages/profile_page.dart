import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';
import 'package:cowork/shared/widgets/resolved_avatar.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).asData?.value;
    return AppScaffold(
      title: 'Profil',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              _ProfileAvatar(photoUrl: user?.photoUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Profil',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    const Text('Profil duzenleme (mock)'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Bu sayfa yakinda duzenleme formu ile doldurulacak.'),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;

  const _ProfileAvatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return ResolvedAvatar(
      photoUrl: photoUrl,
      radius: 36,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      fallback: const Icon(Icons.person_outline),
    );
  }
}
