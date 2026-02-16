import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final List<NavSheetAction> sheetActions;

  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    this.sheetActions = const [],
  });
}

class NavSheetAction {
  final String label;
  final IconData icon;
  final String route;

  const NavSheetAction({
    required this.label,
    required this.icon,
    required this.route,
  });
}
