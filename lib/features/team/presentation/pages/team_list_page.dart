import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/features/users/presentation/controllers/users_controller.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';
import 'package:cowork/shared/widgets/resolved_avatar.dart';

class TeamListPage extends ConsumerWidget {
  const TeamListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).asData?.value;
    final users = ref.watch(usersStreamProvider);

    return AppScaffold(
      title: 'Ekibim',
      child: users.when(
        data: (items) {
          final visible = items
              .where((u) => u.isActive)
              .where((u) => session == null || u.id != session.uid)
              .toList();
          if (visible.isEmpty) {
            return const Center(child: Text('Ekip listesi bos.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = visible[index];
              return Card(
                child: ListTile(
                  leading: ResolvedAvatar(
                    photoUrl: user.photoUrl,
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    fallback: const Icon(Icons.person_outline),
                  ),
                  title: Text(user.fullName),
                  subtitle: Text(user.role),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('${Routes.teamMember}/${user.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
