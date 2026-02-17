import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/shifts/domain/entities/shift.dart';
import 'package:cowork/features/shifts/presentation/controllers/shift_controller.dart';
import 'package:cowork/shared/ui/feedback/app_feedback.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';
import 'package:cowork/shared/widgets/async_elevated_button.dart';

class ShiftCreatePage extends ConsumerWidget {
  const ShiftCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shiftControllerProvider);
    final user = ref.watch(sessionProvider).asData?.value;
    final myAttendance = ref.watch(myAttendanceProvider);

    if (user == null) {
      return const AppScaffold(
        title: 'Attendance',
        child: Center(child: Text('Session not ready.')),
      );
    }

    final checkInLink = _syntheticLink(user.uid, 'check_in');
    final checkOutLink = _syntheticLink(user.uid, 'check_out');

    return AppScaffold(
      title: 'Attendance Actions',
      child: myAttendance.when(
        data: (items) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Synthetic Link (Temporary)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              AsyncElevatedButton(
                loading: state.isLoading,
                onPressed: () => _createFromLink(context, ref, checkInLink),
                child: const Text('Check In (Link)'),
              ),
              const SizedBox(height: 8),
              AsyncElevatedButton(
                loading: state.isLoading,
                onPressed: () => _createFromLink(context, ref, checkOutLink),
                child: const Text('Check Out (Link)'),
              ),
              const SizedBox(height: 8),
              _LinkCard(
                title: 'Check In Link',
                link: checkInLink,
                loading: state.isLoading,
                onUse: () => _createFromLink(context, ref, checkInLink),
              ),
              const SizedBox(height: 10),
              _LinkCard(
                title: 'Check Out Link',
                link: checkOutLink,
                loading: state.isLoading,
                onUse: () => _createFromLink(context, ref, checkOutLink),
              ),
              const SizedBox(height: 20),
              Text(
                'My Attendance Records',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Text('No records yet.')
              else
                ...items.map((e) => _MyAttendanceCard(item: e)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _syntheticLink(String uid, String action) {
    final seed = DateTime.now().microsecondsSinceEpoch;
    final token = '${uid.substring(0, min(uid.length, 6))}-$seed';
    return 'cowork://attendance?uid=$uid&action=$action&token=$token';
  }

  Future<void> _createFromLink(
    BuildContext context,
    WidgetRef ref,
    String link,
  ) async {
    try {
      await ref.read(shiftControllerProvider.notifier).createFromSyntheticLink(
            link,
          );
      if (!context.mounted) return;
      showSuccessSnackBar(context, 'Attendance saved via link.');
    } catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, 'Link action failed: $e');
    }
  }
}

class _MyAttendanceCard extends StatelessWidget {
  const _MyAttendanceCard({required this.item});

  final ShiftAttendance item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          item.eventType == AttendanceEventType.checkIn ? 'Check In' : 'Check Out',
        ),
        subtitle: Text(_formatDateTime(item.eventAt)),
        trailing: Text(_sourceLabel(item.source)),
      ),
    );
  }

  static String _sourceLabel(AttendanceSource source) {
    return switch (source) {
      AttendanceSource.manual => 'Manual',
      AttendanceSource.link => 'Link',
      AttendanceSource.qr => 'QR',
    };
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.title,
    required this.link,
    required this.loading,
    required this.onUse,
  });

  final String title;
  final String link;
  final bool loading;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SelectableText(link),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: link));
                    if (!context.mounted) return;
                    showSuccessSnackBar(context, 'Link copied.');
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: loading ? null : onUse,
                  icon: const Icon(Icons.link_outlined),
                  label: const Text('Use Link'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
