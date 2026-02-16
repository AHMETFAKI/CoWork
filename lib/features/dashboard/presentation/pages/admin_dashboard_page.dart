import 'package:cowork/core/di/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).asData?.value;

    return AppScaffold(
      title: 'Admin',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Admin Dashboard\n'
            'User: ${user?.name ?? '-'}\n'
            'Role: ${user?.role.name ?? AppRole.admin.name}',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(Routes.approvals),
            child: const Text('Approval Inbox'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go(Routes.users),
            child: const Text('User Admin'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go(Routes.requests),
            child: const Text('My Requests'),
          ),
        ],
      ),
    );
  }
}
