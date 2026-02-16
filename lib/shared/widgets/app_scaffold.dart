import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/routing/guards.dart';
import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:firebase_storage/firebase_storage.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final List<_NavSheetAction> sheetActions;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    this.sheetActions = const [],
  });
}

class _NavSheetAction {
  final String label;
  final IconData icon;
  final String route;

  const _NavSheetAction({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showNavigationBar;
  final bool showBack;
  final bool showAppBar;
  final bool showDrawer;
  final bool showProfileAction;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showNavigationBar = true,
    this.showBack = true,
    this.showAppBar = true,
    this.showDrawer = true,
    this.showProfileAction = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(sessionProvider).asData?.value;
    final canPop = showBack && Navigator.of(context).canPop();

    final homeRoute = appUser == null
        ? Routes.login
        : Guards.homeForRole(appUser.role);

    final navItems = _buildNavItems(appUser, homeRoute);
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _resolveSelectedIndex(navItems, location);

    final appBarActions = <Widget>[
      if (actions != null) ...actions!,
      if (showProfileAction && appUser != null)
        IconButton(
          tooltip: 'Profil',
          onPressed: () => context.go(Routes.profile),
          icon: const Icon(Icons.account_circle_outlined),
        ),
    ];

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              centerTitle: true,
              leading: (showDrawer && appUser != null)
                  ? Builder(
                      builder: (context) => SizedBox(
                        width: canPop ? 88 : 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (canPop) const BackButton(),
                            IconButton(
                              tooltip: 'Menu',
                              icon: const Icon(Icons.menu),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : (canPop ? const BackButton() : null),
              leadingWidth: (showDrawer && appUser != null)
                  ? (canPop ? 96 : 56)
                  : null,
              actions: appBarActions,
              toolbarHeight: 64,
              titleSpacing: canPop ? 0 : 16,
              scrolledUnderElevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.6),
                ),
              ),
            )
          : null,
      drawer: showDrawer && appUser != null
          ? _AppDrawer(
              user: appUser,
              onLogout: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go(Routes.login);
              },
            )
          : null,
      body: child,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: showNavigationBar &&
              appUser != null &&
              navItems.isNotEmpty
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                final item = navItems[index];
                if (item.sheetActions.isNotEmpty) {
                  _showNavSheet(context, item.sheetActions);
                } else {
                  context.go(item.route);
                }
              },
              destinations: [
                for (final item in navItems)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            )
          : null,
    );
  }
}

List<_NavItem> _buildNavItems(AppUser? user, String homeRoute) {
  if (user == null) return const [];

  final items = <_NavItem>[
    _NavItem(
      label: 'Ana Sayfa',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      route: homeRoute,
    ),
  ];

  if (user.role == AppRole.employee) {
    items.addAll([
      const _NavItem(
        label: 'Talepler',
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        route: Routes.requests,
        sheetActions: [
          _NavSheetAction(
            label: 'Liste',
            icon: Icons.list_alt_outlined,
            route: Routes.requests,
          ),
          _NavSheetAction(
            label: 'Yeni Talep',
            icon: Icons.add_circle_outline,
            route: Routes.requestCreate,
          ),
        ],
      ),
      const _NavItem(
        label: 'Vardiyalar',
        icon: Icons.schedule_outlined,
        selectedIcon: Icons.schedule,
        route: Routes.shifts,
      ),
      const _NavItem(
        label: 'Gorevler',
        icon: Icons.checklist_outlined,
        selectedIcon: Icons.checklist,
        route: Routes.tasks,
      ),
    ]);
    return items;
  }

  if (user.role == AppRole.manager) {
    items.addAll([
      const _NavItem(
        label: 'Talepler',
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        route: Routes.requests,
        sheetActions: [
          _NavSheetAction(
            label: 'Talepler',
            icon: Icons.list_alt_outlined,
            route: Routes.requests,
          ),
          _NavSheetAction(
            label: 'Onaylar',
            icon: Icons.fact_check_outlined,
            route: Routes.approvals,
          ),
        ],
      ),
      const _NavItem(
        label: 'Vardiyalar',
        icon: Icons.schedule_outlined,
        selectedIcon: Icons.schedule,
        route: Routes.shifts,
        sheetActions: [
          _NavSheetAction(
            label: 'Liste',
            icon: Icons.list_alt_outlined,
            route: Routes.shifts,
          ),
          _NavSheetAction(
            label: 'Olustur',
            icon: Icons.add_to_queue_outlined,
            route: Routes.shiftCreate,
          ),
        ],
      ),
      const _NavItem(
        label: 'Gorevler',
        icon: Icons.checklist_outlined,
        selectedIcon: Icons.checklist,
        route: Routes.tasks,
        sheetActions: [
          _NavSheetAction(
            label: 'Liste',
            icon: Icons.list_alt_outlined,
            route: Routes.tasks,
          ),
          _NavSheetAction(
            label: 'Olustur',
            icon: Icons.playlist_add_outlined,
            route: Routes.taskCreate,
          ),
        ],
      ),
    ]);
    return items;
  }

  items.addAll([
    const _NavItem(
      label: 'Talepler',
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      route: Routes.requests,
      sheetActions: [
        _NavSheetAction(
          label: 'Talepler',
          icon: Icons.list_alt_outlined,
          route: Routes.requests,
        ),
        _NavSheetAction(
          label: 'Onaylar',
          icon: Icons.fact_check_outlined,
          route: Routes.approvals,
        ),
      ],
    ),
    const _NavItem(
      label: 'Gorevler',
      icon: Icons.checklist_outlined,
      selectedIcon: Icons.checklist,
      route: Routes.tasks,
      sheetActions: [
        _NavSheetAction(
          label: 'Liste',
          icon: Icons.list_alt_outlined,
          route: Routes.tasks,
        ),
        _NavSheetAction(
          label: 'Olustur',
          icon: Icons.playlist_add_outlined,
          route: Routes.taskCreate,
        ),
      ],
    ),
    const _NavItem(
      label: 'Vardiyalar',
      icon: Icons.schedule_outlined,
      selectedIcon: Icons.schedule,
      route: Routes.shifts,
      sheetActions: [
        _NavSheetAction(
          label: 'Liste',
          icon: Icons.list_alt_outlined,
          route: Routes.shifts,
        ),
        _NavSheetAction(
          label: 'Olustur',
          icon: Icons.add_to_queue_outlined,
          route: Routes.shiftCreate,
        ),
      ],
    ),
    const _NavItem(
      label: 'Olustur',
      icon: Icons.add_box_outlined,
      selectedIcon: Icons.add_box,
      route: Routes.users,
      sheetActions: [
        _NavSheetAction(
          label: 'Kullanici Olustur',
          icon: Icons.person_add_alt_1_outlined,
          route: Routes.users,
        ),
        _NavSheetAction(
          label: 'Departman Olustur',
          icon: Icons.domain_add_outlined,
          route: Routes.departments,
        ),
      ],
    ),
  ]);

  return items;
}

int _resolveSelectedIndex(List<_NavItem> items, String location) {
  if (items.isEmpty) return 0;
  final index = items.indexWhere(
    (item) => _navItemMatches(item, location),
  );
  return index == -1 ? 0 : index;
}

bool _navItemMatches(_NavItem item, String location) {
  if (_locationMatches(item.route, location)) return true;
  for (final action in item.sheetActions) {
    if (_locationMatches(action.route, location)) return true;
  }
  return false;
}

bool _locationMatches(String route, String location) {
  if (location == route) return true;
  if (location.startsWith('$route/')) return true;
  return false;
}

Future<void> _showNavSheet(
  BuildContext context,
  List<_NavSheetAction> actions,
) async {
  final selectedRoute = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final action in actions)
            ListTile(
              leading: Icon(action.icon),
              title: Text(action.label),
              onTap: () => Navigator.of(sheetContext).pop(action.route),
            ),
        ],
      ),
    ),
  );

  if (selectedRoute == null) return;
  if (!context.mounted) return;
  context.go(selectedRoute);
}

class _AppDrawer extends StatelessWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const _AppDrawer({
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initialsFor(user.name);
    final avatar = _AvatarImage(photoUrl: user.photoUrl);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  avatar.buildAvatar(
                    context,
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    fallback: Text(
                      initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: () => context.go(Routes.profile),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Profili Duzenle'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Profil'),
              onTap: () => context.go(Routes.profile),
            ),
            if (user.role == AppRole.admin)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Audit Logs'),
                onTap: () => context.go(Routes.auditLogs),
              ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cikis'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final word = parts.first;
    return word.length >= 2
        ? word.substring(0, 2).toUpperCase()
        : word.substring(0, 1).toUpperCase();
  }
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
      .toUpperCase();
}

class _AvatarImage {
  final String? photoUrl;

  const _AvatarImage({required this.photoUrl});

  Widget buildAvatar(
    BuildContext context, {
    required double radius,
    required Color backgroundColor,
    required Widget fallback,
  }) {
    final url = photoUrl;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: fallback,
      );
    }

    if (url.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: NetworkImage(url),
      );
    }

    if (url.startsWith('gs://')) {
      return FutureBuilder<String>(
        future: FirebaseStorage.instance.refFromURL(url).getDownloadURL(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: backgroundColor,
              child: fallback,
            );
          }
          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            backgroundImage: NetworkImage(snapshot.data!),
          );
        },
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: fallback,
    );
  }
}
