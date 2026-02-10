import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';

class UsersListSection extends StatelessWidget {
  final AsyncValue<List<UserProfile>> session;
  final Stream<List<UserProfile>> stream;
  final void Function(UserProfile user) onSelect;

  const UsersListSection({
    super.key,
    required this.session,
    required this.stream,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (session.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (session.hasError) {
      return Text('Session error: ${session.error}');
    }
    return StreamBuilder<List<UserProfile>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!;
        if (users.isEmpty) return const Text('No users found.');

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final user = users[index];
            final name = user.fullName.isNotEmpty ? user.fullName : '-';
            final email = user.email.isNotEmpty ? user.email : '-';
            final role = user.role.isNotEmpty ? user.role : '-';
            final dept = (user.departmentId ?? '-');
            return ListTile(
              title: Text(name),
              subtitle: Text(
                'DocID: ${user.id}\nemail: $email\nrole: $role | dept: $dept',
              ),
              onTap: () => onSelect(user),
            );
          },
        );
      },
    );
  }
}
