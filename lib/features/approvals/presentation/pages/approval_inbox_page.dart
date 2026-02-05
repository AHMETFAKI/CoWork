import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../requests/domain/entities/request.dart';
import '../../../requests/presentation/controllers/request_controller.dart';

class ApprovalInboxPage extends ConsumerWidget {
  const ApprovalInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(departmentRequestsProvider);
    final state = ref.watch(requestControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Approval Inbox')),
      body: requests.when(
        data: (items) {
          final pending = items
              .where((r) => r.status == RequestStatus.pending)
              .toList();
          if (pending.isEmpty) {
            return const Center(child: Text('No pending requests.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = pending[index];
              return _ApprovalCard(
                item: item,
                loading: state.isLoading,
                onApprove: () => _updateStatus(
                  context,
                  ref,
                  item.id,
                  RequestStatus.approved,
                ),
                onReject: () => _updateStatus(
                  context,
                  ref,
                  item.id,
                  RequestStatus.rejected,
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

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    RequestStatus status,
  ) async {
    final note = await _askNote(context, status);
    try {
      await ref.read(requestControllerProvider.notifier).updateStatus(
            requestId: requestId,
            status: status,
            comment: note,
          );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  Future<String?> _askNote(BuildContext context, RequestStatus status) async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(status == RequestStatus.approved ? 'Approve' : 'Reject'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                controller.text.trim().isEmpty ? null : controller.text.trim(),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }
}

class _ApprovalCard extends StatelessWidget {
  final Request item;
  final bool loading;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.item,
    required this.loading,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${item.type.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(item.reason),
            const SizedBox(height: 6),
            Text('Requester: ${item.createdByUserId}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: loading ? null : onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : onApprove,
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
