import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/features/departments/domain/entities/department.dart';
import 'package:cowork/features/departments/presentation/controllers/departments_controller.dart';
import 'package:cowork/features/messages/domain/entities/chat_conversation_summary.dart';
import 'package:cowork/features/messages/presentation/controllers/messages_controller.dart';
import 'package:cowork/features/users/domain/entities/user_profile.dart';
import 'package:cowork/features/users/presentation/controllers/users_controller.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';
import 'package:cowork/shared/widgets/resolved_avatar.dart';

class DashboardChatHome extends ConsumerWidget {
  const DashboardChatHome({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).asData?.value;
    final usersAsync = ref.watch(usersDirectoryStreamProvider);
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final departmentsAsync = ref.watch(departmentsDirectoryStreamProvider);

    return AppScaffold(
      title: title,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _showUserPickerSheet(
            context: context,
            sessionUid: session?.uid,
            usersAsync: usersAsync,
            departmentsAsync: departmentsAsync,
          );
        },
        child: const Icon(Icons.add),
      ),
      child: usersAsync.when(
        data: (users) {
          final usersById = {for (final user in users) user.id: user};
          return conversationsAsync.when(
            data: (conversations) {
              if (conversations.isEmpty) {
                return const Center(child: Text('Sohbet yok. Yeni bir sohbet baslatin.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: conversations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final peer = _resolvePeer(
                    conversation: conversation,
                    sessionUid: session?.uid,
                    usersById: usersById,
                  );
                  return Card(
                    child: ListTile(
                      leading: ResolvedAvatar(
                        photoUrl: peer?.photoUrl,
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        fallback: const Icon(Icons.person_outline),
                      ),
                      title: Text(peer?.fullName ?? 'Kullanici'),
                      subtitle: Text(
                        (conversation.lastMessage?.trim().isNotEmpty ?? false)
                            ? conversation.lastMessage!.trim()
                            : 'Henuz mesaj yok',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: peer == null
                          ? null
                          : () => context.push('${Routes.teamMember}/${peer.id}'),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  static UserProfile? _resolvePeer({
    required ChatConversationSummary conversation,
    required String? sessionUid,
    required Map<String, UserProfile> usersById,
  }) {
    for (final participantId in conversation.participantIds) {
      if (participantId != sessionUid && usersById.containsKey(participantId)) {
        return usersById[participantId];
      }
    }
    return null;
  }

  static void _showUserPickerSheet({
    required BuildContext context,
    required String? sessionUid,
    required AsyncValue<List<UserProfile>> usersAsync,
    required AsyncValue<List<Department>> departmentsAsync,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return usersAsync.when(
          data: (users) {
            final departments = departmentsAsync.asData?.value ?? const <Department>[];
            final grouped = _buildDepartmentGroups(
              users: users,
              departments: departments,
              sessionUid: sessionUid,
            );
            if (grouped.isEmpty) {
              return const SizedBox(
                height: 280,
                child: Center(child: Text('Listelenecek kullanici yok.')),
              );
            }
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final group = grouped[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0) ...[
                          Text(
                            'Sohbet Baslat',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          group.departmentName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        for (final user in group.admins)
                          _UserPickerTile(
                            user: user,
                            roleLabel: 'Admin',
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              context.push('${Routes.teamMember}/${user.id}');
                            },
                          ),
                        for (final user in group.managers)
                          _UserPickerTile(
                            user: user,
                            roleLabel: 'Manager',
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              context.push('${Routes.teamMember}/${user.id}');
                            },
                          ),
                        for (final user in group.employees)
                          _UserPickerTile(
                            user: user,
                            roleLabel: 'Employee',
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              context.push('${Routes.teamMember}/${user.id}');
                            },
                          ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                );
              },
            );
          },
          loading: () => const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => SizedBox(
            height: 280,
            child: Center(child: Text('Error: $err')),
          ),
        );
      },
    );
  }

  static List<_DepartmentGroup> _buildDepartmentGroups({
    required List<UserProfile> users,
    required List<Department> departments,
    required String? sessionUid,
  }) {
    final departmentNameById = {
      for (final department in departments) department.id: department.name,
    };
    final byDepartment = <String, List<UserProfile>>{};

    for (final user in users) {
      if (!user.isActive || user.id == sessionUid) continue;
      final key = user.role == 'admin' ? '_admin' : (user.departmentId ?? '_unknown');
      byDepartment.putIfAbsent(key, () => []).add(user);
    }

    final groups = <_DepartmentGroup>[];
    byDepartment.forEach((departmentId, list) {
      final admins = list.where((u) => u.role == 'admin').toList()
        ..sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
      final managers = list.where((u) => u.role == 'manager').toList()
        ..sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
      final employees = list.where((u) => u.role == 'employee').toList()
        ..sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
      if (admins.isEmpty && managers.isEmpty && employees.isEmpty) return;

      groups.add(
        _DepartmentGroup(
          departmentName: departmentId == '_admin'
              ? 'Admin'
              : (departmentNameById[departmentId] ?? 'Departman Yok'),
          admins: admins,
          managers: managers,
          employees: employees,
        ),
      );
    });

    groups.sort((a, b) => a.departmentName.toLowerCase().compareTo(b.departmentName.toLowerCase()));
    return groups;
  }
}

class _DepartmentGroup {
  final String departmentName;
  final List<UserProfile> admins;
  final List<UserProfile> managers;
  final List<UserProfile> employees;

  const _DepartmentGroup({
    required this.departmentName,
    required this.admins,
    required this.managers,
    required this.employees,
  });
}

class _UserPickerTile extends StatelessWidget {
  const _UserPickerTile({
    required this.user,
    required this.roleLabel,
    required this.onTap,
  });

  final UserProfile user;
  final String roleLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: ResolvedAvatar(
          photoUrl: user.photoUrl,
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          fallback: const Icon(Icons.person_outline),
        ),
        title: Text(user.fullName),
        subtitle: Text(roleLabel),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
