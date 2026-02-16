import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/shared/widgets/resolved_avatar.dart';

class AppDrawer extends StatelessWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initialsFor(user.name);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  ResolvedAvatar(
                    photoUrl: user.photoUrl,
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    fallback: Text(
                      initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: () => context.go(Routes.profile),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Profili Duzenle'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Profil'),
              onTap: () => context.go(Routes.profile),
            ),
            if (user.role == AppRole.admin)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Audit Logs'),
                onTap: () => context.go(Routes.auditLogs),
              ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cikis'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final word = parts.first;
    return word.length >= 2 ? word.substring(0, 2).toUpperCase() : word.substring(0, 1).toUpperCase();
  }
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}
