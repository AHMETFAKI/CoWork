import 'package:flutter/material.dart';

PreferredSizeWidget? buildAppTopBar({
  required BuildContext context,
  required String title,
  required bool showAppBar,
  required bool showDrawer,
  required bool canPop,
  required bool hasUser,
  required List<Widget> actions,
}) {
  if (!showAppBar) return null;

  return AppBar(
    title: Text(title),
    centerTitle: true,
    leading: (showDrawer && hasUser)
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
    leadingWidth: (showDrawer && hasUser) ? (canPop ? 96 : 56) : null,
    actions: actions,
    toolbarHeight: 64,
    titleSpacing: canPop ? 0 : 16,
    scrolledUnderElevation: 0,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
      ),
    ),
  );
}
