import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

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
      body: Center(
        child: Text(
          'Manager Dashboard\n'
              'User: ${user?.name ?? '-'}\n'
              'Dept: ${user?.departmentId ?? '-'}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
