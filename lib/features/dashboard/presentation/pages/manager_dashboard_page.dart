import 'package:cowork/core/di/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';

class ManagerDashboardPage extends ConsumerWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).asData?.value;

    return AppScaffold(
      title: 'Manager',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Manager Dashboard\n'
            'User: ${user?.name ?? '-'}\n'
            'Dept: ${user?.departmentId ?? '-'}',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(Routes.approvals),
            child: const Text('Approval Inbox'),
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
