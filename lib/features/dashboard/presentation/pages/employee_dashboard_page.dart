import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';

class EmployeeDashboardPage extends ConsumerWidget {
  const EmployeeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).asData?.value;

    return AppScaffold(
      title: 'Employee',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Employee Dashboard\n'
            'User: ${user?.name ?? '-'}',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(Routes.requests),
            child: const Text('My Requests'),
          ),
        ],
      ),
    );
  }
}
