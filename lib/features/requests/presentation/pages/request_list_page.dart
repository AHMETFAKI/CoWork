import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../domain/entities/request.dart';
import '../controllers/request_controller.dart';

class RequestListPage extends ConsumerWidget {
  const RequestListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(myRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: requests.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No requests yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _RequestCard(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Routes.requestCreate),
        label: const Text('Create Request'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Request item;

  const _RequestCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _typeLabel(item.type),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(item.reason),
            const SizedBox(height: 6),
            Text('Status: ${_statusLabel(item.status)}'),
            if (item.amount != null)
              Text('Amount: ${item.amount} ${item.currency ?? ''}'.trim()),
            if (item.startDate != null && item.endDate != null)
              Text('Dates: ${_formatDate(item.startDate!)} - ${_formatDate(item.endDate!)}'),
            if (item.category?.isNotEmpty == true)
              Text('Category: ${item.category}'),
          ],
        ),
      ),
    );
  }

  String _typeLabel(RequestType type) {
    return switch (type) {
      RequestType.leave => 'Leave',
      RequestType.advance => 'Advance',
      RequestType.expense => 'Expense',
    };
  }

  String _statusLabel(RequestStatus status) {
    return switch (status) {
      RequestStatus.pending => 'Pending',
      RequestStatus.approved => 'Approved',
      RequestStatus.rejected => 'Rejected',
      RequestStatus.cancelled => 'Cancelled',
    };
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
