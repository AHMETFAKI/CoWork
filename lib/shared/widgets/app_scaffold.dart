import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/core/routing/guards.dart';
import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cowork/shared/widgets/app_scaffold/app_drawer.dart';
import 'package:cowork/shared/widgets/app_scaffold/app_top_bar.dart';
import 'package:cowork/shared/widgets/app_scaffold/nav.dart';

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
    final homeRoute = appUser == null ? Routes.login : Guards.homeForRole(appUser.role);
    final navItems = buildNavItems(appUser, homeRoute);
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = resolveSelectedIndex(navItems, location);

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
      appBar: buildAppTopBar(
        context: context,
        title: title,
        showAppBar: showAppBar,
        showDrawer: showDrawer,
        canPop: canPop,
        hasUser: appUser != null,
        actions: appBarActions,
      ),
      drawer: showDrawer && appUser != null
          ? AppDrawer(
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
      bottomNavigationBar: showNavigationBar && appUser != null && navItems.isNotEmpty
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                final item = navItems[index];
                if (item.sheetActions.isNotEmpty) {
                  showNavSheet(context, item.sheetActions);
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
