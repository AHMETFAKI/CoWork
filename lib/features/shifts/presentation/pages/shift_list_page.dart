import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/features/shifts/domain/entities/shift.dart';
import 'package:cowork/features/shifts/presentation/controllers/shift_controller.dart';
import 'package:cowork/features/users/domain/entities/user_profile.dart';
import 'package:cowork/features/users/presentation/controllers/users_controller.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';

enum _RangeFilter { today, last3Days, lastWeek, lastMonth }

class ShiftListPage extends ConsumerStatefulWidget {
  const ShiftListPage({super.key});

  @override
  ConsumerState<ShiftListPage> createState() => _ShiftListPageState();
}

class _ShiftListPageState extends ConsumerState<ShiftListPage> {
  _RangeFilter _filter = _RangeFilter.today;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).asData?.value;
    final attendance = ref.watch(visibleShiftsProvider);
    final users = ref.watch(usersStreamProvider);

    return AppScaffold(
      title: 'Attendance List',
      child: attendance.when(
        data: (items) {
          final filtered = _applyFilter(items, _filter);
          return users.when(
            data: (userList) {
              final userNames = _userNameMap(session, userList);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Wrap(
                      spacing: 8,
                      children: _RangeFilter.values.map((value) {
                        return ChoiceChip(
                          label: Text(_filterLabel(value)),
                          selected: _filter == value,
                          onSelected: (_) => setState(() => _filter = value),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No attendance records in this range.'))
                        : _buildBody(
                            session: session,
                            items: filtered,
                            userNames: userNames,
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Routes.shiftCreate),
        label: const Text('Check In/Out'),
        icon: const Icon(Icons.qr_code_2_outlined),
      ),
    );
  }

  Widget _buildBody({
    required AppUser? session,
    required List<ShiftAttendance> items,
    required Map<String, String> userNames,
  }) {
    if (session?.role == AppRole.employee) {
      final stats = _buildStats(items);
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatsCard(
            name: userNames[session!.uid] ?? session.uid,
            stats: stats,
            records: items,
            showUserInRows: false,
            userNames: userNames,
          ),
        ],
      );
    }

    final byRole = <String, List<ShiftAttendance>>{};
    for (final item in items) {
      byRole.putIfAbsent(item.userRole, () => []).add(item);
    }
    final roleOrder = ['admin', 'manager', 'employee'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: roleOrder
          .where(byRole.containsKey)
          .map(
            (role) => _RoleSection(
              role: role,
              items: byRole[role]!,
              userNames: userNames,
            ),
          )
          .toList(),
    );
  }

  List<ShiftAttendance> _applyFilter(
    List<ShiftAttendance> items,
    _RangeFilter filter,
  ) {
    final now = DateTime.now();
    final start = switch (filter) {
      _RangeFilter.today => DateTime(now.year, now.month, now.day),
      _RangeFilter.last3Days => DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 2)),
      _RangeFilter.lastWeek => DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 6)),
      _RangeFilter.lastMonth => DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 29)),
    };
    return items.where((e) => !e.eventAt.isBefore(start)).toList();
  }

  String _filterLabel(_RangeFilter filter) {
    return switch (filter) {
      _RangeFilter.today => 'Today',
      _RangeFilter.last3Days => 'Last 3 Days',
      _RangeFilter.lastWeek => 'Last Week',
      _RangeFilter.lastMonth => 'Last Month',
    };
  }

  Map<String, String> _userNameMap(AppUser? session, List<UserProfile> users) {
    final map = <String, String>{
      for (final user in users) user.id: user.fullName,
    };
    if (session != null) {
      map.putIfAbsent(session.uid, () => session.name);
    }
    return map;
  }
}

class _RoleSection extends StatelessWidget {
  const _RoleSection({
    required this.role,
    required this.items,
    required this.userNames,
  });

  final String role;
  final List<ShiftAttendance> items;
  final Map<String, String> userNames;

  @override
  Widget build(BuildContext context) {
    final byUser = <String, List<ShiftAttendance>>{};
    for (final item in items) {
      byUser.putIfAbsent(item.userId, () => []).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_roleLabel(role), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...byUser.entries.map((entry) {
          final records = entry.value;
          final stats = _buildStats(records);
          final userName = userNames[entry.key] ?? entry.key;
          return _StatsCard(
            name: userName,
            stats: stats,
            records: records,
            showUserInRows: false,
            userNames: userNames,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  static String _roleLabel(String role) {
    return switch (role) {
      'admin' => 'Admins',
      'manager' => 'Managers',
      _ => 'Employees',
    };
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.name,
    required this.stats,
    required this.records,
    required this.showUserInRows,
    required this.userNames,
  });

  final String name;
  final _AttendanceStats stats;
  final List<ShiftAttendance> records;
  final bool showUserInRows;
  final Map<String, String> userNames;

  @override
  Widget build(BuildContext context) {
    final totalHours = (stats.totalWorked.inMinutes / 60).toStringAsFixed(1);
    final firstInText =
        stats.firstCheckIn == null ? '-' : _formatDateTime(stats.firstCheckIn!);
    final lastOutText =
        stats.lastCheckOut == null ? '-' : _formatDateTime(stats.lastCheckOut!);

    return Card(
      child: ExpansionTile(
        title: Text(name),
        subtitle: Text(
          'In: ${stats.checkInCount}  Out: ${stats.checkOutCount}  Hours: $totalHours',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('First In: $firstInText'),
                Text('Last Out: $lastOutText'),
                const SizedBox(height: 8),
                Text(
                  'Daily Work Graph',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _WorkHoursChart(days: stats.daily),
                const SizedBox(height: 10),
                Text(
                  'All Records',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          ...records
              .map(
                (item) => _AttendanceRow(
                  item: item,
                  showUser: showUserInRows,
                  userNames: userNames,
                ),
              )
              .toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.item,
    required this.showUser,
    required this.userNames,
  });

  final ShiftAttendance item;
  final bool showUser;
  final Map<String, String> userNames;

  @override
  Widget build(BuildContext context) {
    final eventLabel = item.eventType == AttendanceEventType.checkIn
        ? 'Check In'
        : 'Check Out';
    final name = userNames[item.userId] ?? item.userId;

    return ListTile(
      title: Text(showUser ? '$name - $eventLabel' : eventLabel),
      subtitle: Text('${_formatDateTime(item.eventAt)} | ${_sourceLabel(item.source)}'),
      trailing: item.tokenId == null
          ? null
          : const Icon(Icons.verified_outlined, size: 18),
    );
  }
}

class _WorkHoursChart extends StatelessWidget {
  const _WorkHoursChart({required this.days});

  final List<_DayStat> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const Text('No complete in/out session yet.');
    }

    final maxMinutes = days
        .map((e) => e.worked.inMinutes)
        .fold<int>(0, (prev, current) => current > prev ? current : prev);

    return Column(
      children: days.map((day) {
        final minutes = day.worked.inMinutes;
        final factor = maxMinutes == 0 ? 0.0 : minutes / maxMinutes;
        final hours = (minutes / 60).toStringAsFixed(1);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 52, child: Text(_shortDate(day.day))),
              Expanded(
                child: Stack(
                  children: [
                    Container(height: 12, color: Colors.grey.shade300),
                    FractionallySizedBox(
                      widthFactor: factor.clamp(0.0, 1.0),
                      child: Container(height: 12, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 56, child: Text('$hours h')),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AttendanceStats {
  const _AttendanceStats({
    required this.checkInCount,
    required this.checkOutCount,
    required this.totalWorked,
    required this.firstCheckIn,
    required this.lastCheckOut,
    required this.daily,
  });

  final int checkInCount;
  final int checkOutCount;
  final Duration totalWorked;
  final DateTime? firstCheckIn;
  final DateTime? lastCheckOut;
  final List<_DayStat> daily;
}

class _DayStat {
  const _DayStat({
    required this.day,
    required this.worked,
  });

  final DateTime day;
  final Duration worked;
}

_AttendanceStats _buildStats(List<ShiftAttendance> records) {
  final sorted = [...records]..sort((a, b) => a.eventAt.compareTo(b.eventAt));
  var checkInCount = 0;
  var checkOutCount = 0;
  Duration totalWorked = Duration.zero;
  DateTime? firstIn;
  DateTime? lastOut;
  DateTime? pendingIn;
  final byDay = <DateTime, Duration>{};

  for (final item in sorted) {
    final day = DateTime(item.eventAt.year, item.eventAt.month, item.eventAt.day);
    if (item.eventType == AttendanceEventType.checkIn) {
      checkInCount++;
      firstIn = firstIn == null || item.eventAt.isBefore(firstIn) ? item.eventAt : firstIn;
      pendingIn = item.eventAt;
      continue;
    }

    checkOutCount++;
    lastOut = lastOut == null || item.eventAt.isAfter(lastOut) ? item.eventAt : lastOut;
    if (pendingIn != null && item.eventAt.isAfter(pendingIn!)) {
      final diff = item.eventAt.difference(pendingIn!);
      totalWorked += diff;
      byDay[day] = (byDay[day] ?? Duration.zero) + diff;
      pendingIn = null;
    }
  }

  final daily = byDay.entries
      .map((e) => _DayStat(day: e.key, worked: e.value))
      .toList()
    ..sort((a, b) => b.day.compareTo(a.day));

  return _AttendanceStats(
    checkInCount: checkInCount,
    checkOutCount: checkOutCount,
    totalWorked: totalWorked,
    firstCheckIn: firstIn,
    lastCheckOut: lastOut,
    daily: daily,
  );
}

String _sourceLabel(AttendanceSource source) {
  return switch (source) {
    AttendanceSource.manual => 'Manual',
    AttendanceSource.link => 'Link',
    AttendanceSource.qr => 'QR',
  };
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String _shortDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month';
}
