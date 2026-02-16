import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/shared/widgets/app_scaffold/nav_configs.dart';
import 'package:cowork/shared/widgets/app_scaffold/nav_models.dart';

List<NavItem> buildNavItems(AppUser? user, String homeRoute) {
  if (user == null) return const [];

  return <NavItem>[
    NavItem(
      label: 'Ana Sayfa',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      route: homeRoute,
    ),
    ...(roleNavItems[user.role] ?? const <NavItem>[]),
  ];
}

int resolveSelectedIndex(List<NavItem> items, String location) {
  if (items.isEmpty) return 0;
  final index = items.indexWhere((item) => _navItemMatches(item, location));
  return index == -1 ? 0 : index;
}

bool _navItemMatches(NavItem item, String location) {
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

Future<void> showNavSheet(BuildContext context, List<NavSheetAction> actions) async {
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
