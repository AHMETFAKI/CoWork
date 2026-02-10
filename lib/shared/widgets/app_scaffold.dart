import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/guards.dart';
import '../../core/routing/routes.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/domain/entities/app_user.dart';

enum _AppMenuAction {
  home,
  requests,
  approvals,
  users,
  departments,
  logout,
  login,
}

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showMenu;
  final bool showBack;
  final bool showAppBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showMenu = true,
    this.showBack = true,
    this.showAppBar = true,
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

    final menuItems = <PopupMenuEntry<_AppMenuAction>>[];
    if (appUser == null) {
      menuItems.add(
        const PopupMenuItem(
          value: _AppMenuAction.login,
          child: Text('Login'),
        ),
      );
    } else {
      menuItems.addAll([
        const PopupMenuItem(
          value: _AppMenuAction.home,
          child: Text('Ana Sayfa'),
        ),
        const PopupMenuItem(
          value: _AppMenuAction.requests,
          child: Text('Talepler'),
        ),
        const PopupMenuItem(
          value: _AppMenuAction.approvals,
          child: Text('Onaylar'),
        ),
        const PopupMenuItem(
          value: _AppMenuAction.users,
          child: Text('Kullanicilar'),
        ),
        if (appUser.role == AppRole.admin)
          const PopupMenuItem(
            value: _AppMenuAction.departments,
            child: Text('Departmanlar'),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _AppMenuAction.logout,
          child: Text('Cikis'),
        ),
      ]);
    }

    final appBarActions = <Widget>[
      if (actions != null) ...actions!,
      if (showMenu && menuItems.isNotEmpty)
        PopupMenuButton<_AppMenuAction>(
          onSelected: (value) async {
            switch (value) {
              case _AppMenuAction.home:
                context.go(homeRoute);
                break;
              case _AppMenuAction.requests:
                context.go(Routes.requests);
                break;
              case _AppMenuAction.approvals:
                context.go(Routes.approvals);
                break;
              case _AppMenuAction.users:
                context.go(Routes.users);
                break;
              case _AppMenuAction.departments:
                context.go(Routes.departments);
                break;
              case _AppMenuAction.logout:
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go(Routes.login);
                break;
              case _AppMenuAction.login:
                context.go(Routes.login);
                break;
            }
          },
          itemBuilder: (_) => menuItems,
        ),
    ];

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              leading: canPop ? const BackButton() : null,
              actions: appBarActions,
            )
          : null,
      body: child,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
