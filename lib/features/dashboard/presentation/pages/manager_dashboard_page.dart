import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/routing/routes.dart';

class ManagerDashboardPage extends ConsumerWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
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
